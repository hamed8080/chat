//
// ChatFileManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatExtensions
import ChatModels
import Foundation

final class ChatFileManager: FileProtocol {
    let chat: ChatInternalProtocol
    var delegate: ChatDelegate? { chat.delegate }
    var cache: CacheManager? { chat.cache }
    private var tasks: [String: URLSessionTask] = [:]

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func upload(_ request: UploadImageRequest) {
        upload(request, nil, nil)
    }

    func upload(_ request: UploadFileRequest) {
        upload(request, nil, nil)
    }

    internal func upload(_ request: UploadImageRequest, _ progress: UploadFileProgressType? = nil, _ completion: UploadCompletionType? = nil) {
        let params = UploadManagerParameters(request, chat.config)
        upload(params, request.data, progress, completion)
    }

    internal func upload(_ request: UploadFileRequest, _ progress: UploadFileProgressType? = nil, _ completion: UploadCompletionType? = nil) {
        let params = UploadManagerParameters(request, chat.config)
        upload(params, request.data, progress, completion)
    }

    private func upload(_ req: UploadManagerParameters, _ fileData: Data, _ progress: UploadFileProgressType? = nil, _ completion: UploadCompletionType? = nil) {
        let task = UploadManager(chat: chat).upload(req, fileData, progress: progress) { data, _, error in
            self.onUploadCompleted(req, data, error, completion)
        }
        tasks[req.uniqueId] = task
    }

    func uploadHasError(_ data: Data?, _ error: Error?) -> ChatError? {
        guard let data = data else { return ChatError(rawError: error) }
        let chatError = try? JSONDecoder.instance.decode(ChatError.self, from: data)
        let uploadResponse = try? JSONDecoder.instance.decode(PodspaceFileUploadResponse.self, from: data)
        if chatError?.hasError == true {
            return chatError
        } else if let error = uploadResponse?.error {
            return ChatError(message: error, code: uploadResponse?.errorType?.rawValue)
        } else if let error = error {
            return ChatError(rawError: error)
        } else {
            return nil /// Sucess upload.
        }
    }

    private func onUploadCompleted(_ req: UploadManagerParameters, _ data: Data?, _ error: Error?, _ uploadCompletion: UploadCompletionType?) {
        // completed upload file
        if let error = uploadHasError(data, error) {
            delegate?.chatEvent(event: .upload(.failed(uniqueId: req.uniqueId, error: error)))
        } else if let data = data, let uploadResponse = try? JSONDecoder.instance.decode(PodspaceFileUploadResponse.self, from: data) {
            chat.logger.logJSON(title: "File uploaded successfully", jsonString: data.utf8StringOrEmpty, persist: false, type: .internalLog)
            let fileMetaData = uploadResponse.toMetaData(chat.config, width: req.imageRequest?.wC, height: req.imageRequest?.hC)
            uploadCompletion?(uploadResponse.result, fileMetaData, nil)
            delegate?.chatEvent(event: .upload(.completed(uniqueId: req.uniqueId, fileMetaData: fileMetaData, data: data, error: nil)))
            cache?.deleteQueues(uniqueIds: [req.uniqueId])
        }
    }

    func manageUpload(uniqueId: String, action: DownloaUploadAction) {
        if let task = tasks[uniqueId] {
            switch action {
            case .cancel:
                task.cancel()
                removeTask(uniqueId)
                delegate?.chatEvent(event: .upload(.canceled(uniqueId: uniqueId)))
                cache?.deleteQueues(uniqueIds: [uniqueId])
            case .suspend:
                task.suspend()
                delegate?.chatEvent(event: .upload(.suspended(uniqueId: uniqueId)))
            case .resume:
                task.resume()
                delegate?.chatEvent(event: .upload(.resumed(uniqueId: uniqueId)))
            }
        } else {
            delegate?.chatEvent(event: .upload(.failed(uniqueId: uniqueId, error: nil)))
        }
    }

    func manageDownload(uniqueId: String, action: DownloaUploadAction) {
        if let task = tasks[uniqueId] {
            switch action {
            case .cancel:
                task.cancel()
                delegate?.chatEvent(event: .download(.canceled(uniqueId: uniqueId)))
                removeTask(uniqueId)
            case .suspend:
                task.suspend()
                delegate?.chatEvent(event: .download(.suspended(uniqueId: uniqueId)))
            case .resume:
                task.resume()
                delegate?.chatEvent(event: .download(.resumed(uniqueId: uniqueId)))
            }
        } else {
            delegate?.chatEvent(event: .download(.failed(uniqueId: uniqueId, error: nil)))
        }
    }

    public func get(_ request: ImageRequest) {
        let url = "\(chat.config.fileServer)\(Routes.images.rawValue)/\(request.hashCode)"
        /// Check if either the image exists in the cache. or not, if it doesn't exist force to download property has become true.
        var forceToDownloadFromServer = false
        if chat.cacheFileManager?.isFileExist(url: URL(string: url)!) == false {
            forceToDownloadFromServer = true
        }
        if request.forceToDownloadFromServer == true {
            forceToDownloadFromServer = true
        }
        let request = ImageRequest(request: request, forceToDownloadFromServer: forceToDownloadFromServer)
        if request.forceToDownloadFromServer == true {
            let headers = ["Authorization": "Bearer \(chat.config.token)"]
            let task = DownloadManager(chat: chat)
                .download(url: url,
                          uniqueId: request.chatUniqueId,
                          headers: headers,
                          parameters: try? request.asDictionary()) { [weak self] progress in
                    self?.delegate?.chatEvent(event: .download(.progress(uniqueId: request.uniqueId, progress: progress)))
                } completion: { [weak self] data, response, error in
                    self?.onDownload(hashCode: request.hashCode, uniqueId: request.uniqueId, url: url, data: data, response: response, error: error, isImage: true)
                }
            tasks[request.uniqueId] = task
        }

        if let filePath = chat.cacheFileManager?.filePath(url: URL(string: url)!) {
            cache?.image?.first(hashCode: request.hashCode) { [weak self] _ in
                self?.chat.responseQueue.async {
                    let data = self?.chat.cacheFileManager?.getData(url: filePath) ?? self?.chat.cacheFileManager?.getDataInGroup(url: filePath)
                    let response = ChatResponse(uniqueId: request.uniqueId, result: data)
                    self?.delegate?.chatEvent(event: .download(.image(response, filePath)))
                }
            }
        }
    }

    public func get(_ request: FileRequest) {
        let url = "\(chat.config.fileServer)\(Routes.files.rawValue)/\(request.hashCode)"
        /// Check if either the file exists in the cache. or not, if it doesn't exist force to download property has become true.
        var forceToDownloadFromServer = false
        if chat.cacheFileManager?.isFileExist(url: URL(string: url)!) == false {
            forceToDownloadFromServer = true
        }
        if request.forceToDownloadFromServer == true {
            forceToDownloadFromServer = true
        }
        let request = FileRequest(request: request, forceToDownloadFromServer: forceToDownloadFromServer)
        if request.forceToDownloadFromServer == true {
            let headers = ["Authorization": "Bearer \(chat.config.token)"]
            let task = DownloadManager(chat: chat)
                .download(url: url,
                          uniqueId: request.chatUniqueId,
                          headers: headers,
                          parameters: try? request.asDictionary()) { [weak self] progress in
                    self?.delegate?.chatEvent(event: .download(.progress(uniqueId: request.uniqueId, progress: progress)))
                } completion: { [weak self] data, response, error in
                    self?.onDownload(hashCode: request.hashCode, uniqueId: request.uniqueId, url: url, data: data, response: response, error: error)
                }
            tasks[request.uniqueId] = task
        }

        if let filePath = chat.cacheFileManager?.filePath(url: URL(string: url)!) {
            cache?.file?.first(hashCode: request.hashCode) { [weak self] _ in
                self?.chat.responseQueue.async {
                    let data = self?.chat.cacheFileManager?.getData(url: filePath) ?? self?.chat.cacheFileManager?.getDataInGroup(url: filePath)
                    let response = ChatResponse(uniqueId: request.uniqueId, result: data)
                    self?.delegate?.chatEvent(event: .download(.file(response, filePath)))
                }
            }
        }
    }

    func onDownload(hashCode: String, uniqueId: String, url: String, data: Data?, response: URLResponse?, error _: Error?, isImage: Bool = false) {
        guard let response = response as? HTTPURLResponse,
              let headers = response.allHeaderFields as? [String: Any]
        else { return }
        let statusCode = response.statusCode
        if let errorResponse = error(statusCode: statusCode, data: data, uniqueId: uniqueId, headers: headers) {
            delegate?.chatEvent(event: .system(.error(errorResponse)))
        } else {
            var name: String?
            if let fileName = (headers["Content-Disposition"] as? String)?.replacingOccurrences(of: "\"", with: "").split(separator: "=").last {
                name = String(fileName)
            }
            var type: String?
            if let mimetype = (headers["Content-Type"] as? String)?.split(separator: "/").last {
                type = String(mimetype)
            }
            let size = Int((headers["Content-Length"] as? String) ?? "0")
            let fileNameWithExtension = "\(name ?? "default").\(type ?? "none")"
            let file = File(hashCode: hashCode, name: fileNameWithExtension, size: size, type: type)
            cache?.file?.insert(models: [file])
            chat.cacheFileManager?.saveFile(url: URL(string: url)!, data: data ?? Data()) { [weak self] filePath in
                let response = ChatResponse(uniqueId: uniqueId, result: data)
                self?.delegate?.chatEvent(event: .download(isImage ? .image(response, filePath) : .file(response, filePath)))
            }
        }
    }

    private func error(statusCode: Int, data: Data?, uniqueId: String, headers: [String: Any]) -> ChatResponse<Any>? {
        if statusCode >= 200, statusCode <= 300 {
            if let data = data, let error = try? JSONDecoder.instance.decode(ChatError.self, from: data), error.hasError == true {
                let response = ChatResponse(uniqueId: uniqueId, result: Any?.none, error: error)
                return response
            }
            if let data = data, let podspaceError = try? JSONDecoder.instance.decode(PodspaceFileUploadResponse.self, from: data) {
                let error = ChatError(message: podspaceError.message, code: podspaceError.errorType?.rawValue, hasError: true)
                let response = ChatResponse(uniqueId: uniqueId, result: Any?.none, error: error)
                return response
            }
            return nil /// Means the result was success.
        } else {
            let message = (headers["errorMessage"] as? String) ?? ""
            let code = (headers["errorCode"] as? Int) ?? 999
            let error = ChatError(message: message, code: code, hasError: true, content: nil)
            let response = ChatResponse(uniqueId: uniqueId, result: Any?.none, error: error)
            return response
        }
    }

    /// Delete a file in cache. with exact file url on the disk.
    func deleteCacheFile(_ url: URL) {
        chat.cacheFileManager?.deleteFile(at: url)
    }

    /// Return true if the file exist inside the sandbox of the ChatSDK application host.
    func isFileExist(_ url: URL) -> Bool {
        chat.cacheFileManager?.isFileExist(url: url) ?? false
    }

    /// Return the url of the file if it exists inside the sandbox of the ChatSDK application host.
    func filePath(_ url: URL) -> URL? {
        chat.cacheFileManager?.filePath(url: url)
    }

    /// Return the true of the file if it exists inside the share group.
    func isFileExistInGroup(_ url: URL) -> Bool {
        chat.cacheFileManager?.isFileExistInGroup(url: url) ?? false
    }

    /// Return the url of the file if it exists inside the share group.
    func filePathInGroup(_ url: URL) -> URL? {
        chat.cacheFileManager?.filePathInGroup(url: url)
    }

    /// Get data of a cache. file in the correspondent URL.
    func getData(_ url: URL) -> Data? {
        chat.cacheFileManager?.getData(url: url)
    }

    /// Get data of a cache. file in the correspondent URL inside a shared group.
    func getDataInGroup(_ url: URL) -> Data? {
        chat.cacheFileManager?.getDataInGroup(url: url)
    }

    /// Save a file inside the sandbox of the Chat SDK.
    func saveFile(url: URL, data: Data, completion: @escaping (URL?) -> Void) {
        chat.cacheFileManager?.saveFile(url: url, data: data, saveCompeletion: completion)
    }

    /// Save a file inside a shared group.
    func saveFileInGroup(url: URL, data: Data, completion: @escaping (URL?) -> Void) {
        chat.cacheFileManager?.saveFileInGroup(url: url, data: data, saveCompeletion: completion)
    }

    private func removeTask(_ uniqueId: String) {
        if let task = tasks[uniqueId] {
            task.cancel()
            tasks.removeValue(forKey: uniqueId)
        }
    }
}
