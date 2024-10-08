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

final class ChatFileManager: FileProtocol, InternalFileProtocol {
    let chat: ChatInternalProtocol
    var delegate: ChatDelegate? { chat.delegate }
    var cache: CacheManager? { chat.cache }
    typealias SessionAndTask = (session: URLSession, task: URLSessionDataTaskProtocol?)

    // Keep track of requests, to do internal actions such as adding the user to the user group if needed.
    private var requests: [String: DownloadManagerParameters] = [:]
    private var tasks: [String: SessionAndTask] = [:]
    private var queue = DispatchQueue(label: "DownloadQueue")

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
        let uploadProgress: UploadProgressType = { [weak self] progress in
            self?.delegate?.chatEvent(event: .upload(.progress(req.uniqueId, progress)))
            progressCompletion?(progress)
        }
        let delegate = ProgressImplementation(uniqueId: req.uniqueId, uploadProgress: uploadProgress)
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        let task = UploadManager().upload(req, data, session) { [weak self] respData, response, error in
            self?.onUploadCompleted(req, respData, error, data, completion)
        }
        addTask(uniqueId: req.uniqueId, session: session, task: task)
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

    private func onUploadCompleted(_ req: UploadManagerParameters, _ responseData: Data?, _ error: Error?, _ fileData: Data, _ uploadCompletion: UploadCompletionType?) {
        // completed upload file
        if let error = uploadHasError(responseData, error) {
            delegate?.chatEvent(event: .upload(.failed(uniqueId: req.uniqueId, error: error)))
        } else if let data = responseData, let uploadResponse = try? JSONDecoder.instance.decode(PodspaceFileUploadResponse.self, from: data) {
            chat.logger.logJSON(title: "File uploaded successfully", jsonString: data.utf8StringOrEmpty, persist: false, type: .internalLog)
            let fileMetaData = uploadResponse.toMetaData(chat.config, width: req.imageRequest?.wC, height: req.imageRequest?.hC)
            uploadCompletion?(uploadResponse.result, fileMetaData, nil)
            delegate?.chatEvent(event: .upload(.completed(uniqueId: req.uniqueId, fileMetaData: fileMetaData, data: data, error: nil)))
            cache?.deleteQueues(uniqueIds: [req.uniqueId])
            if chat.config.saveOnUpload == true {
                saveUploadedFile(req ,uploadResponse, fileData)
            }
        }
        removeTask(req.uniqueId)
    }

    private func saveUploadedFile(_ params: UploadManagerParameters, _ response: PodspaceFileUploadResponse, _ fileData: Data) {
        let config = chat.config
        let isImage = params.imageRequest != nil
        guard let hashCode = response.result?.hash else { return }
        var url: URL?
        if isImage {
            url = URL(string: "\(config.fileServer)\(Routes.images.rawValue)/\(hashCode)")!
        } else {
            url = URL(string: "\(config.fileServer)\(Routes.files.rawValue)/\(hashCode)")!
        }
        guard let url = url else { return }
        chat.cacheFileManager?.saveFile(url: url, data: fileData) {_ in}
    }

    func manageUpload(uniqueId: String, action: DownloaUploadAction) {
        manageTask(upload: true, uniqueId: uniqueId, action: action)
    }

    func manageDownload(uniqueId: String, action: DownloaUploadAction) {
        manageTask(upload: false, uniqueId: uniqueId, action: action)
    }

    private func manageTask(upload: Bool, uniqueId: String, action: DownloaUploadAction) {
        if let task = getTask(uniqueId: uniqueId)?.task {
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
            log("Start downloading with params:\n\(params.debugDescription)")
            let delegate = ProgressImplementation(uniqueId: params.uniqueId, uploadProgress: nil) { [weak self] progress in
                self?.delegate?.chatEvent(event: .download(.progress(uniqueId: params.uniqueId, progress: progress)))
            } downloadCompletion: { [weak self] data, response, error in
                self?.log("Download completed with response:\(String(describing: response)) error:\(String(describing: error)) params:\n\(params.debugDescription)")
                self?.onDownload(params: params, data: data, response: response, error: error)
            }
            let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: .main)
            let task = DownloadManager.download(params, session)
            addTask(uniqueId: params.uniqueId, session: session, task: task)
        } else {
            log("Start fetching from cache with params:\n\(params.debugDescription)")
            fetchFromCache(params)
        }
    }


    private func log(_ message: String) {
#if DEBUG
        chat.logger.log(title: "ChatFileManager", message: message, persist: false, type: .internalLog)
#endif
    }

    private func fetchFromCache(_ params: DownloadManagerParameters) {
        if let filePath = chat.cacheFileManager?.filePath(url: params.url), let hashCode = params.hashCode {
            cache?.file?.first(hashCode: hashCode) { [weak self] _ in
                self?.chat.cacheFileManager?.getData(url: params.url) { [weak self] data in
                    self?.log("On cache file for non-group with params:\n\(params.debugDescription)")
                    let response = ChatResponse(uniqueId: params.uniqueId, result: data, cache: true, typeCode: nil)
                    self?.delegate?.chatEvent(event: .download(params.isImage ? .image(response, filePath) : .file(response, filePath)))
                }

                self?.chat.cacheFileManager?.getDataInGroup(url: params.url) { [weak self] data in
                    self?.log("On cache file for group with params:\n\(params.debugDescription)")
                    let response = ChatResponse(uniqueId: params.uniqueId, result: data, cache: true, typeCode: nil)
                    self?.delegate?.chatEvent(event: .download(params.isImage ? .image(response, filePath) : .file(response, filePath)))
                }
            }
        }
    }

    func onDownload(params: DownloadManagerParameters, data: Data?, response: URLResponse?, error _: Error?) {
        guard let response = response as? HTTPURLResponse,
              let headers = response.allHeaderFields as? [String: Any]
        else { return }
        let statusCode = response.statusCode
        if let errorResponse = handleDownloadError(statusCode, params, data, headers) {
            delegate?.chatEvent(event: .system(.error(errorResponse)))
            removeTask(params.uniqueId)
        } else if let data = data {
            let response = ChatResponse(uniqueId: params.uniqueId, result: data, typeCode: nil)
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
            removeTask(params.uniqueId)
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
    func getData(_ url: URL, completion: @escaping (Data?) -> Void) {
        chat.cacheFileManager?.getData(url: url) { data in
            completion(data)
        }
    }

    /// Get data of a cache. file in the correspondent URL inside a shared group.
    func getDataInGroup(_ url: URL, completion: @escaping (Data?) -> Void) {
        chat.cacheFileManager?.getDataInGroup(url: url) { data in
            completion(data)
        }
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
        queue.async { [weak self] in
            guard let self = self else { return }
            if let sessionandTask = tasks[uniqueId] {
                sessionandTask.session.invalidateAndCancel()
                tasks.removeValue(forKey: uniqueId)
            }
        }
    }

    private func addTask(uniqueId: String, session: URLSession, task: URLSessionDataTaskProtocol?) {
        queue.async { [weak self] in
            guard let self = self else { return }
            tasks[uniqueId] = (session, task)
        }
    }

    private func getTask(uniqueId: String) -> SessionAndTask? {
        queue.sync {
            return tasks[uniqueId]
        }
    }

    internal func handleUserGroupAccessError(_ params: DownloadManagerParameters) {
        guard let conversationId = params.conversationId else { return }
        let req = AddUserToUserGroupRequest(conversationId: conversationId, typeCodeIndex: params.typeCodeIndex)
        queue.sync {
            requests[req.uniqueId] = params
        }
        chat.prepareToSendAsync(req: req, type: .addUserToUserGroup)

        /// Timer to cancel download and raise an error.
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            _ = queue.sync {
                self.requests.removeValue(forKey: req.uniqueId)
            }
        }
    }

    internal func onAddUserToUserGroup(_ asyncMessage: AsyncMessage) {
        let uniqueId = asyncMessage.chatMessage?.uniqueId
        queue.sync {
            if let uniqueId = uniqueId, let params = requests[uniqueId] {
                retry(params)
                requests.removeValue(forKey: uniqueId)
            }
        }
    }

    private func retry(_ params: DownloadManagerParameters) {
        download(params)
    }
}


// MARK: handle Errors
extension ChatFileManager {
    private func handleDownloadError(_ statusCode: Int, _ params: DownloadManagerParameters, _ data: Data?, _ headers: [String: Any]) -> ChatResponse<Any>? {
        let typeCode = chat.config.typeCodes[params.typeCodeIndex].typeCode
        if statusCode >= 200, statusCode <= 300 {
            if let chatError = chatError(params.uniqueId, data, typeCode) {
                return chatError
            }
            if let podSpaceError = podspaceError(params.uniqueId, data, typeCode) {
                if podSpaceError.error?.code == 403 {
                    return checkForAccessError(params, typeCode)
                } else {
                    return podSpaceError
                }
            }
            return nil // nil means it was successful.
        } else {
            return unhandledError(params, headers, typeCode)
        }
    }

    private func unhandledError(_ params: DownloadManagerParameters, _ headers: [String: Any], _ typeCode: String) -> ChatResponse<Any>? {
        let message = (headers["errorMessage"] as? String) ?? ""
        let code = (headers["errorCode"] as? Int) ?? 999
        let error = ChatError(message: message, code: code, hasError: true, content: nil)
        return ChatResponse(uniqueId: params.uniqueId, result: Any?.none, error: error, typeCode: typeCode)
    }

    private func checkForAccessError(_ params: DownloadManagerParameters, _ typeCode: String) -> ChatResponse<Any>? {
        let error = ChatError(type: .notAddedInUserGroup, code: 403)
        handleUserGroupAccessError(params)
        return ChatResponse(uniqueId: params.uniqueId, result: Any?.none, error: error, typeCode: typeCode)
    }

    private func chatError(_ uniqueId: String, _ data: Data?, _ typeCode: String) -> ChatResponse<Any>? {
        if let data = data, let error = try? JSONDecoder.instance.decode(ChatError.self, from: data), error.hasError == true {
            return ChatResponse(uniqueId: uniqueId, result: Any?.none, error: error, typeCode: typeCode)
        }
        return nil
    }

    private func podspaceError(_ uniqueId: String?, _ data: Data?, _ typeCode: String) -> ChatResponse<Any>? {
        if let data = data, let podspaceError = try? JSONDecoder.instance.decode(PodspaceFileUploadResponse.self, from: data) {
            let error = ChatError(message: podspaceError.message, code: podspaceError.errorType?.rawValue, hasError: true)
            return ChatResponse(uniqueId: uniqueId, result: Any?.none, error: error, typeCode: typeCode)
        }
        return nil
    }
}
