//
// ChatFileManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Additive
import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatExtensions
import ChatModels
import ChatTransceiver
import Foundation

final class ChatFileManager: FileProtocol {
    let chat: ChatInternalProtocol
    var delegate: ChatDelegate? { chat.delegate }
    var cache: CacheManager? { chat.cache }
    private var tasks: [String: URLSessionDataTaskProtocol] = [:]

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func upload(_ request: UploadImageRequest) {
        upload(request, nil, nil)
    }

    func upload(_ request: UploadFileRequest) {
        upload(request, nil, nil)
    }

    internal func upload(_ request: UploadImageRequest, _ progress: UploadProgressType? = nil, _ completion: UploadCompletionType? = nil) {
        let params = UploadManagerParameters(request, token: chat.config.token, fileServer: chat.config.fileServer)
        upload(params, request.data, progress, completion)
    }

    internal func upload(_ request: UploadFileRequest, _ progress: UploadProgressType? = nil, _ completion: UploadCompletionType? = nil) {
        let params = UploadManagerParameters(request, token: chat.config.token, fileServer: chat.config.fileServer)
        upload(params, request.data, progress, completion)
    }

    private func upload(_ req: UploadManagerParameters, _ data: Data, _ progressCompletion: UploadProgressType? = nil, _ completion: UploadCompletionType? = nil) {
        let task = UploadManager().upload(req, data) { [weak self] progress in
            self?.delegate?.chatEvent(event: .upload(.progress(req.uniqueId, progress)))
            progressCompletion?(progress)
        } completion: { data, _, error in
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
        manageTask(upload: true, uniqueId: uniqueId, action: action)
    }

    func manageDownload(uniqueId: String, action: DownloaUploadAction) {
        manageTask(upload: false, uniqueId: uniqueId, action: action)
    }

    private func manageTask(upload: Bool, uniqueId: String, action: DownloaUploadAction) {
        if let task = tasks[uniqueId] {
            switch action {
            case .cancel:
                task.cancel()
                delegate?.chatEvent(event: upload ? .upload(.canceled(uniqueId: uniqueId)) : .download(.canceled(uniqueId: uniqueId)))
                removeTask(uniqueId)
                cache?.deleteQueues(uniqueIds: [uniqueId])
            case .suspend:
                task.suspend()
                delegate?.chatEvent(event: upload ? .upload(.suspended(uniqueId: uniqueId)) : .download(.suspended(uniqueId: uniqueId)))
            case .resume:
                task.resume()
                delegate?.chatEvent(event: upload ? .upload(.resumed(uniqueId: uniqueId)) : .download(.resumed(uniqueId: uniqueId)))
            }
        } else {
            delegate?.chatEvent(event: upload ? .upload(.failed(uniqueId: uniqueId, error: nil)) : .download(.failed(uniqueId: uniqueId, error: nil)))
        }
    }

    public func get(_ request: ImageRequest) {
        let params = DownloadManagerParameters(request, chat.config, chat.cacheFileManager)
        download(params)
    }

    public func get(_ request: FileRequest) {
        let params = DownloadManagerParameters(request, chat.config, chat.cacheFileManager)
        download(params)
    }

    private func download(_ params: DownloadManagerParameters) {
        if params.forceToDownload {
            let task = DownloadManager().download(params) { [weak self] progress in
                self?.delegate?.chatEvent(event: .download(.progress(uniqueId: params.uniqueId, progress: progress)))
            } completion: { [weak self] data, response, error in
                self?.onDownload(params: params, data: data, response: response, error: error)
            }
            tasks[params.uniqueId] = task
        }

        if let filePath = chat.cacheFileManager?.filePath(url: params.url), let hashCode = params.hashCode {
            cache?.file?.first(hashCode: hashCode) { [weak self] _ in
                let data = self?.chat.cacheFileManager?.getData(url: params.url) ?? self?.chat.cacheFileManager?.getDataInGroup(url: params.url)
                let response = ChatResponse(uniqueId: params.uniqueId, result: data, cache: true)
                self?.delegate?.chatEvent(event: .download(params.isImage ? .image(response, filePath) : .file(response, filePath)))
            }
        }
    }

    func onDownload(params: DownloadManagerParameters, data: Data?, response: URLResponse?, error _: Error?) {
        guard let response = response as? HTTPURLResponse,
              let headers = response.allHeaderFields as? [String: Any]
        else { return }
        let statusCode = response.statusCode
        if let errorResponse = error(statusCode: statusCode, data: data, uniqueId: params.uniqueId, headers: headers) {
            delegate?.chatEvent(event: .system(.error(errorResponse)))
        } else if let data = data {
            let response = ChatResponse(uniqueId: params.uniqueId, result: data)
            if !params.thumbnail {
                let file = File(hashCode: params.hashCode ?? "", headers: headers)
                cache?.file?.insert(models: [file])
                chat.cacheFileManager?.saveFile(url: params.url, data: data) { [weak self] filePath in
                    self?.delegate?.chatEvent(event: .download(params.isImage ? .image(response, filePath) : .file(response, filePath)))
                }
            } else {
                /// Is thumbnail and it does not need to save on the disk.
                delegate?.chatEvent(event: .download(params.isImage ? .image(response, nil) : .file(response, nil)))
            }
        }
    }

    private func error(statusCode: Int, data: Data?, uniqueId: String, headers: [String: Any]) -> ChatResponse<Any>? {
        if statusCode >= 200, statusCode <= 300 {
            if let data = data, let error = try? JSONDecoder.instance.decode(ChatError.self, from: data), error.hasError == true {
                return ChatResponse(uniqueId: uniqueId, result: Any?.none, error: error)
            }
            if let data = data, let podspaceError = try? JSONDecoder.instance.decode(PodspaceFileUploadResponse.self, from: data) {
                let error = ChatError(message: podspaceError.message, code: podspaceError.errorType?.rawValue, hasError: true)
                return ChatResponse(uniqueId: uniqueId, result: Any?.none, error: error)
            }
            return nil /// Means the result was success.
        } else {
            let message = (headers["errorMessage"] as? String) ?? ""
            let code = (headers["errorCode"] as? Int) ?? 999
            let error = ChatError(message: message, code: code, hasError: true, content: nil)
            return ChatResponse(uniqueId: uniqueId, result: Any?.none, error: error)
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
