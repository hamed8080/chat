//
// ProgressImplementation.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
final class ProgressImplementation: NSObject, URLSessionDataDelegate, URLSessionTaskDelegate {
    private let uploadProgress: UploadFileProgressType?
    private let downloadProgress: DownloadProgressType?
    private var buffer: NSMutableData = .init()
    private var downloadCompletion: ((Data?, HTTPURLResponse?, Error?) -> Void)?
    private var downloadFileProgress = DownloadFileProgress(percent: 0, totalSize: 0, bytesRecivied: 0)
    private var response: HTTPURLResponse?
    private var uniqueId: String
    private weak var delegate: ChatDelegate?
    private var logger: Logger?

    init(delegate: ChatDelegate? = nil, logger: Logger? = nil, uniqueId: String, uploadProgress: UploadFileProgressType? = nil, downloadProgress: DownloadProgressType? = nil, downloadCompletion: ((Data?, HTTPURLResponse?, Error?) -> Void)? = nil) {
        self.uniqueId = uniqueId
        self.delegate = delegate
        self.logger = logger
        self.uploadProgress = uploadProgress
        self.downloadProgress = downloadProgress
        self.downloadCompletion = downloadCompletion
    }

    // MARK: - Upload progress Delegates

    func urlSession(_: URLSession, task _: URLSessionTask, didSendBodyData _: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let percent = (Float(totalBytesSent) / Float(totalBytesExpectedToSend)) * 100
        logger?.log(title: "Upload progress:\(percent)", persist: false, type: .internalLog)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.uploadProgress?(UploadFileProgress(percent: Int64(percent), totalSize: totalBytesExpectedToSend, bytesSend: totalBytesSent), nil)
            let response: ChatResponse<String> = .init(uniqueId: self.uniqueId, result: self.uniqueId)
            self.delegate?.chatEvent(event: .file(.uploading(response)))
        }
    }

    // MARK: - END Upload progress Delegates

    // MARK: - Download progress Delegates

    func urlSession(_: URLSession, dataTask _: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.response = response as? HTTPURLResponse
        downloadFileProgress.totalSize = response.expectedContentLength
        downloadProgress?(downloadFileProgress)
        logger?.log(title: "Download progress:\(downloadFileProgress.percent)", persist: false, type: .internalLog)
        completionHandler(.allow)
        let response: ChatResponse<String> = .init(uniqueId: uniqueId, result: uniqueId)
        delegate?.chatEvent(event: .file(.downloading(response)))
    }

    func urlSession(_: URLSession, dataTask _: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)

        let percentageDownloaded: Double
        if downloadFileProgress.totalSize == -1 {
            percentageDownloaded = 0
        } else {
            percentageDownloaded = Double(buffer.count) / Double(downloadFileProgress.totalSize)
        }
        downloadFileProgress.bytesRecivied = Int64(buffer.count)
        downloadFileProgress.percent = Int64(percentageDownloaded * 100)
        downloadProgress?(downloadFileProgress)
    }

    func urlSession(_: URLSession, task _: URLSessionTask, didCompleteWithError error: Error?) {
        guard let url = response?.url else { return }
        let headers = response?.allHeaderFields as? [String: String] ?? [:]
        let resultResponse = HTTPURLResponse(url: url, statusCode: error == nil ? 200 : 400, httpVersion: "HTTP/1.1", headerFields: headers)
        downloadCompletion?(buffer as Data, resultResponse, error)
    }

    // MARK: - END Download progress Delegates
}
