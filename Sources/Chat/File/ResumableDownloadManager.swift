//
// ResumableDownloadManager.swift
// Copyright (c) 2022 ChatTransceiver
//
// Created by Hamed Hosseini on 11/2/22
//

import Foundation
import ChatModels
import ChatCache
import ChatCore

@ChatGlobalActor
final class ResumableDownloadManager: NSObject {
    private let chat: ChatInternalProtocol
    private var resumableDownloads: [Int: ResumableModel] = [:]
    private var delegate: ChatDelegate? { chat.delegate }
    private var cache: CacheManager? { chat.cache }
    private var fm: CacheFileManagerProtocol? { chat.cacheFileManager }
    
    init(chat: ChatInternalProtocol) {
        self.chat = chat
        try? (chat.cacheFileManager as? CacheFileManager)?.createResumableDirectory()
    }
    
    private func log(_ message: String) {
#if DEBUG
        chat.logger.log(title: "ChatFileManager", message: message, persist: false, type: .internalLog)
#endif
    }
}

extension ResumableDownloadManager {
    func download(_ request: FileRequest) throws {
        let params = DownloadManagerParameters(request, chat.config, fm)
        if let _ = fm?.resumableData(for: params.hashCode ?? "") {
            try resumeDownloading(params: params)
            return
        }
        let req = DownloadManager.urlRequest(params: params)
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        let task = session.dataTask(with: req)
        resumableDownloads[task.taskIdentifier] = ResumableModel(task: task, params: params, resumableDIR: resumableDIR)
        task.resume()
    }
    
    func pauseResumableDownload(hashCode: String) throws {
        guard let model = model(hashCode: hashCode) else {
            throw NSError(domain: "Pausing download has failed", code: 0)
        }
        
        /// Suspend or pause the download.
        model.task.suspend()
        
        /// Notify that the download has been paused.
        delegate?.chatEvent(event: .download(.suspended(uniqueId: model.params.uniqueId)))
    }
    
    func resumeDownloading(hashCode: String) throws {
        if let params = model(hashCode: hashCode)?.params {
            try resumeDownloading(params: params)
        }
    }
    
    private func resumeDownloading(params: DownloadManagerParameters) throws {
        let attributes = try FileManager.default.attributesOfItem(atPath: resumableDIR.appendingPathComponent(params.hashCode ?? "").path)
        guard let size = attributes[.size] as? NSNumber else {
            throw NSError(domain: "Failed to find a resumeData file with hashCode: \(params.hashCode ?? "")", code: 0)
        }
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        var req = DownloadManager.urlRequest(params: params)
        req.addValue("bytes=\(size.intValue))-", forHTTPHeaderField: "Range")
        let newResumeTask = session.dataTask(with: req)
        let model = ResumableModel(task: newResumeTask, params: params, resumableDIR: resumableDIR)
        model.downloadedBytes = size.intValue
        resumableDownloads[newResumeTask.taskIdentifier] = model
        
        newResumeTask.resume()
        delegate?.chatEvent(event: .download(.resumed(uniqueId: params.uniqueId)))
    }
    
    func cancel(hashCode: String) throws {
        guard let model = model(hashCode: hashCode) else { return }
        
        /// Clean up the task.
        model.task.cancel()
        model.outputsStream?.close()
        resumableDownloads.removeValue(forKey: model.task.taskIdentifier)
        
        try fm?.deleteResumeDataFile(hashCode: hashCode)
    }
}

/// Resumeable Download Tasks delegate
extension ResumableDownloadManager: URLSessionDataDelegate {

    nonisolated func urlSession(_: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        Task { @ChatGlobalActor in
            guard let model = resumableDownloads[dataTask.taskIdentifier] else { return }
            
            let totalSize = response.expectedContentLength
            let isResumed = (response as? HTTPURLResponse)?.statusCode == 206
            
            if isResumed {
                model.totalFileSize = Int64(totalSize) + Int64(model.downloadedBytes)
            } else {
                model.totalFileSize = totalSize
            }
        }
        completionHandler(.allow)
    }

    nonisolated func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        Task { @ChatGlobalActor in
            guard let model = model(taskIdentifier: dataTask.taskIdentifier) else {
                log("Could not find the task \(dataTask.taskIdentifier)")
                return
            }
            
            /// Append new data buffer to the outputStream.
            _ = data.withUnsafeBytes { pointer in
                model.outputsStream?.write(pointer.bindMemory(to: Int8.self).baseAddress!, maxLength: data.count)
            }
            
            /// Update progress bar delegate.
            let totalReceived = model.downloadedBytes + data.count
            let percent = (Float(totalReceived) / Float(model.totalFileSize)) * 100
            let progress = DownloadFileProgress(percent: Int64(percent), totalSize: model.totalFileSize, bytesRecivied: Int64(data.count))
            delegate?.chatEvent(event: .download(.progress(uniqueId: model.params.uniqueId, progress: progress)))
            
            /// Update downloaded bytes.
            resumableDownloads[dataTask.taskIdentifier]?.downloadedBytes = totalReceived
        }
    }
    
    nonisolated func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        Task { @ChatGlobalActor in
            guard let model = model(taskIdentifier: task.taskIdentifier) else { return }
            if let error = error as? URLError {
                log("Resumable download failed with taskId: \(task.taskIdentifier) with error: \(error.localizedDescription)")
                let error = ChatError(rawError: error)
                delegate?.chatEvent(event: .download(.failed(uniqueId: model.params.uniqueId, error: error)))
            } else if !model.params.thumbnail {
                /// Handle download completion without any error.
                model.outputsStream?.close()
                
                let params = model.params
                
                /// Store it in Core data.
                let file = File(hashCode: params.hashCode ?? "", headers: params.headers)
                cache?.file?.insert(models: [file])
                
                /// Store and move it permanently inside documents folder.
                guard let filePath = await fm?.saveFile(url: params.url, tempDownloadFileURL: model.tempFileURL) else { return }
                
                /// Create a response with file path on the disk, and notify the delegate.
                let response = ChatResponse(uniqueId: params.uniqueId, result: filePath, typeCode: nil)
                delegate?.chatEvent(event: .download(params.isImage ? .downloadImage(response) : .downloadFile(response)))
                
                /// Clean up the reference.
                resumableDownloads.removeValue(forKey: model.task.taskIdentifier)
                
                /// Delete the resumeData file if there is any.
                try? fm?.deleteResumeDataFile(hashCode: params.hashCode ?? "")
            }
        }
    }
    
    private func model(taskIdentifier: Int) -> ResumableModel? {
        resumableDownloads.first(where: {$0.key == taskIdentifier})?.value
    }
    
    private func model(hashCode: String) -> ResumableModel? {
        resumableDownloads.first(where: {$0.value.params.hashCode == hashCode})?.value
    }
    
    private var resumableDIR: URL {
        (fm as? CacheFileManager)?.resumableDIR ?? FileManager.default.temporaryDirectory
    }
}

fileprivate class ResumableModel {
    let task: URLSessionDataTask
    let params: DownloadManagerParameters
    var totalFileSize: Int64 = -1
    var tempFileURL: URL
    var downloadedBytes: Int = 0
    var outputsStream: OutputStream?
    
    init(task: URLSessionDataTask, params: DownloadManagerParameters, totalFileSize: Int64 = -1, resumableDIR: URL) {
        self.task = task
        self.params = params
        self.totalFileSize = totalFileSize
        self.tempFileURL = resumableDIR.appendingPathComponent(params.hashCode ?? "")
        self.outputsStream = OutputStream(url: tempFileURL, append: true)
        self.outputsStream?.open()
    }
}
