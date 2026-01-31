//
//  MultiPartFileStreamURL.swift
//  ChatTransceiver
//
//  Created by Hamed Hosseini on 7/19/25.
//

import Foundation
import UniformTypeIdentifiers

/// Actor that coordinates a streamed multipart/form-data upload.
/// Memory use is O(header+footer+small chunk); file is streamed from disk.
class MultiPartFileStreamURL {
    // MARK: - Immutable
    private let completion: @Sendable (Result<Data, Error>) -> Void
    private let progressCompletion: UploadProgressType
    private let params: UploadManagerParameters
    private let totalLength: Int
    private let boundary = "Boundary-\(UUID().uuidString)"
    
    // MARK: - State
    private var responseData = Data()
    private var session: URLSession? = nil
    
    // MARK: - Self-retention property
    // This strong reference to self ensures the MultipartUploader instance
    // stays alive for the duration of the upload task.
    private var strongSelf: MultiPartFileStreamURL?
    
    /// Initializes the MultipartUploader with the file to upload and a completion handler.
    /// - Parameters:
    ///   - fileURL: The URL of the file to be uploaded.
    ///   - completion: A closure to be called upon completion of the upload,
    ///                 receiving either the response Data or an Error.
    init?(params: UploadManagerParameters, completion: @escaping @Sendable (Result<Data, Error>) -> Void, progressCompletion: @escaping UploadProgressType) {
        guard let filePath = params.fileRequest?.filePath else { return nil }
        
        self.params = params
        self.completion = completion
        self.progressCompletion = progressCompletion
        
        let headerData = MultiPartFileStreamURL.header(mimeType: params.mimeType, boundary: boundary, fileName: params.fileName)
        let footerData = MultiPartFileStreamURL.footer(boundary: boundary)
        totalLength = headerData.count + Int(params.fileRequest?.fileSize ?? 0) + footerData.count
        
        // Initialize the delegate here with all required data.
        // The delegate now holds the header, footer, and fileURL directly.
        let delegateProxy = SessionDelegate(owner: self,
                                            headerData: headerData,
                                            footerData: footerData,
                                            fileURL: filePath,
                                            progressCompletion: progressCompletion)
        
        // Session is initialized here, but the delegate will be set up in `upload`
        // once all the necessary data for the delegate is computed.
        self.session = URLSession(configuration: .default,
                                  delegate: delegateProxy, // Delegate is set later
                                  delegateQueue: nil)
        
        // Retain self to ensure the uploader stays alive during the operation.
        self.strongSelf = self
    }
    
    /// Initiates the file upload to the specified URL.
    /// - Parameters:
    ///   - params: Parameters to upload a file like mimetype, file size,...
    func upload() -> (URLSessionUploadTask, URLSession)? {
        guard let uploadURL = URL(string: params.url) else { return nil }
        
        var req = URLRequest(url: uploadURL)
        req.httpMethod = "POST"
    
        // Set necessary HTTP headers.
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        req.setValue(String(totalLength), forHTTPHeaderField: "Content-Length")
        // Add any extra headers provided by the caller.
        params.headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }
    
        // Create an task the upload task with streamed request.
        // This tells URLSession to ask the delegate for an InputStream for the body.
        let task = session?.uploadTask(withStreamedRequest: req)
        task?.resume()
        guard let session = session, let task = task else { return nil }
        return (task, session)
    }
    
    // MARK: - Actor-internal mutation from delegate (called by SessionDelegate)
    
    /// Appends received response data.
    /// This method is called by the SessionDelegate when response data is received.
    fileprivate func appendResponseData(_ newData: Data) {
        responseData.append(newData)
    }
    
    /// Handles the completion of the upload task.
    /// This method is called by the SessionDelegate when the task finishes (successfully or with an error).
    /// - Parameter error: An optional error if the task failed.
    fileprivate func finished(error: Error?) {
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(responseData))
        }
        // Invalidate the session to clean up resources.
        // This is important to release the delegate and other associated objects.
        session?.invalidateAndCancel()
        
        // Release self-retention once the operation is complete.
        self.strongSelf = nil
    }
    
    class func header(mimeType: String?, boundary: String, fileName: String) -> Data {
        let headerData =
        Data("--\(boundary)\r\n".utf8) +
        Data("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".utf8) +
        Data("Content-Type: \(mimeType ?? "application/octet-stream")\r\n\r\n".utf8)
        return headerData
    }
    
    class func footer(boundary: String) -> Data {
        Data("\r\n--\(boundary)--\r\n".utf8)
    }
    
    func cancel() {
        if let delegate = session?.delegate as? SessionDelegate {
            delegate.task?.cancel()
        }
        session?.invalidateAndCancel()
        session = nil
        strongSelf = nil
    }
}

/// A pure ObjC-compatible delegate for URLSession that manages the streamed multipart body.
/// It uses bound streams to provide data to URLSession asynchronously.
/// Marked as @unchecked Sendable because it manages mutable state that might be accessed
/// by URLSession on a background queue, but access is coordinated to be safe.
private final class SessionDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate, @unchecked Sendable {
    // Use weak to avoid a strong reference cycle with MultipartUploader.
    weak var owner: MultiPartFileStreamURL?
    let chunkSize: Int = 64 * 1024 // Define a chunk size for reading file data (64 KB).
    
    // Body components are now non-optional and initialized directly.
    private let headerData: Data
    private let footerData: Data
    private let fileURL: URL
    public var task: Task<Void, Never>?
    
    // Stream management properties.
    private var currentOffset: Int = 0      // Current offset in the file for reading.
    let progressCompletion: UploadProgressType
    
    /// Initializes the SessionDelegate with its owning MultipartUploader and all necessary data.
    /// - Parameters:
    ///   - owner: The MultipartUploader instance that owns this delegate.
    ///   - headerData: The multipart header data.
    ///   - footerData: The multipart footer data.
    ///   - fileURL: The URL of the file to be streamed.
    init(owner: MultiPartFileStreamURL, headerData: Data, footerData: Data, fileURL: URL, progressCompletion: @escaping UploadProgressType) {
        self.owner = owner
        self.headerData = headerData
        self.footerData = footerData
        self.fileURL = fileURL
        self.progressCompletion = progressCompletion
        super.init()
    }
    
    // MARK: - URLSessionTaskDelegate methods
    
    /// Called by URLSession when it needs a new body stream for the upload task.
    /// This is where we create the bound streams and start writing data to the output stream asynchronously.
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        // No more guards for headerData, footerData, fileURL as they are non-optional.
        
        var inStreamOpt: InputStream?
        var outStreamOpt: OutputStream?
        // Create a pair of bound streams. URLSession will read from inStream, we write to outStream.
        Stream.getBoundStreams(withBufferSize: chunkSize,
                               inputStream: &inStreamOpt,
                               outputStream: &outStreamOpt)
        
        guard let inStream = inStreamOpt, let outStream = outStreamOpt else {
            // If stream creation fails, complete with an error.
            owner?.finished(error: NSError(domain: "MultipartUploaderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create bound streams"]))
            self.task?.cancel()
            self.task = nil
            completionHandler(nil)
            return
        }
        
        outStream.open() // Open the output stream.
        
        // Immediately provide the input stream to URLSession.
        // This fulfills URLSession's request without delaying.
        completionHandler(inStream)
        
        // Start writing data to the outputStream in a background Task.
        let task = Task { [weak self] in
            guard let self = self else { return }
            await writeAllStreams(outStream)
        }
        self.task = task
    }
    
    private func writeAllStreams(_ outStream: OutputStream) async {
        var fileHandle: FileHandle?
        do {
            fileHandle = try FileHandle(forReadingFrom: fileURL)
            
            // Write the multipart header.
            _ = await writeAll(outStream, headerData)
            
            // Write the file bytes in chunks.
            if #available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *), let fileHandle = fileHandle {
                try await writeFileStream(outStream, fileHandle)
            }
            
            // Write the multipart footer.
            _ = await writeAll(outStream, footerData)
            
            // Close the output stream and file handle once all data has been written.
            outStream.close()
            try? fileHandle?.close()
        } catch {
            print("Error writing to output stream: \(error.localizedDescription)")
            owner?.finished(error: error)
            // Ensure streams are closed on error to prevent resource leaks.
            outStream.close()
            try? fileHandle?.close()
            
            self.task?.cancel()
            self.task = nil
        }
    }
    
    /// Called by URLSession when data is received from the server.
    /// - Parameters:
    ///   - session: The URLSession object.
    ///   - dataTask: The data task that received the data.
    ///   - data: The data received.
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive data: Data) {
        guard let owner = owner else { return }
        owner.appendResponseData(data)
    }
    
    /// Called by URLSession when the task completes (successfully or with an error).
    /// - Parameters:
    ///   - session: The URLSession object.
    ///   - task: The task that completed.
    ///   - error: An optional error if the task failed.
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        guard let owner = owner else { return }
        owner.finished(error: error)
        self.task?.cancel()
        self.task = nil
    }
    
    // MARK: - Bound-stream multipart body helper functions
    
    /// Writes the file content to the output stream in chunks.
    /// - Parameters:
    ///   - outStream: The OutputStream to write to.
    ///   - fh: The FileHandle for reading the file.
    /// - Throws: An error if writing fails.
    @available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *)
    func writeFileStream(_ outStream: OutputStream, _ fh: FileHandle) async throws {
        // Seek to the current offset. This is important for retries or if `needNewBodyStream` is called again.
        try fh.seek(toOffset: UInt64(currentOffset))
        
        while true {
            // ⛔️ Check for cancellation before proceeding
            if Task.isCancelled {
                throw CancellationError()
            }
            
            // Crucial for flow control: wait until the output stream has space available.
            // This prevents overwhelming the stream's buffer and ensures data is written
            // only when URLSession is ready to consume it.
            while !outStream.hasSpaceAvailable {
                if Task.isCancelled {
                    throw CancellationError()
                }
                
                // Yield the task to allow other tasks (including URLSession's reading) to run.
                await Task.yield()
                try? await Task.sleep(nanoseconds: 1_000_000) // 1ms
            }
            
            // Safely unwrap the optional Data returned by read(upToCount:).
            // If nil is returned, it means the end of the file has been reached.
            guard let chunk = try fh.read(upToCount: chunkSize) else {
                break // End of file has been reached.
            }
            
            if chunk.isEmpty {
                break // End of file has been reached.
            }
            
            let success = await writeAll(outStream, chunk)
            if !success {
                throw NSError(domain: "MultipartUploaderError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to write data to output stream"])
            }
            currentOffset += chunk.count
        }
    }
    
    /// Writes all data to the output stream.
    /// - Parameters:
    ///   - outStream: The OutputStream to write to.
    ///   - data: The Data to write.
    /// - Returns: True if all data was written successfully, false otherwise.
    func writeAll(_ outStream: OutputStream, _ data: Data) async -> Bool {
        var offset = 0
        // Get a pointer to the data's bytes. This is a synchronous operation.
        let rawBuf = data.withUnsafeBytes { $0 }
        guard let base = rawBuf.baseAddress else { return false }
        
        while offset < data.count {
            if Task.isCancelled {
                return false
            }
            
            // Again, check for space available before attempting to write.
            while !outStream.hasSpaceAvailable {
                if Task.isCancelled {
                    return false
                }
                await Task.yield()
                try? await Task.sleep(nanoseconds: 1_000_000) // 1ms
            }
            let written = outStream.write(base.advanced(by: offset),
                                          maxLength: data.count - offset)
            if written <= 0 {
                // 0 indicates no bytes were written (e.g., buffer full, though `hasSpaceAvailable` should prevent this),
                // -1 indicates an error.
                return false
            }
            offset += written
        }
        return true
    }
    
    func urlSession(_: URLSession, task _: URLSessionTask, didSendBodyData _: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let percent = (Float(totalBytesSent) / Float(totalBytesExpectedToSend)) * 100
        let uploadProgress = UploadFileProgress(percent: Int64(percent), totalSize: totalBytesExpectedToSend, bytesSend: totalBytesSent)
        self.progressCompletion(uploadProgress)
    }
}
