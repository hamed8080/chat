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
    private var fm: CacheFileManagerProtocol? { chat.cacheFileManager }
    private lazy var resumableDownlaodManager: ResumableDownloadManager = {
        let manager = ResumableDownloadManager(chat: chat)
        return manager
    }()

    // Keep track of requests, to do internal actions such as adding the user to the user group if needed.
    private var requests: [String: DownloadManagerParameters] = [:]
    private var tasks: [String: SessionAndTask] = [:]
    private var uploadManagers: [String: UploadManager] = [:]
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
        let url = url(imageRequest: request, fileServer: chat.config.spec.server.file)
        let params = UploadManagerParameters(url: url, request, token: chat.config.token)
        upload(params, request.data, progress, completion)
    }

    internal func upload(_ request: UploadFileRequest, _ progress: UploadProgressType? = nil, _ completion: UploadCompletionType? = nil) {
        let url = url(fileRequest: request, fileServer: chat.config.spec.server.file)
        let params = UploadManagerParameters(url: url, request, token: chat.config.token)
        if request.filePath != nil {
            upload(params, progress, completion)
        } else {
            upload(params, request.data, progress, completion)
        }
    }
    
    private func url(imageRequest: UploadImageRequest? = nil, fileRequest: UploadFileRequest? = nil, fileServer: String) -> String {
        let userGroupHash = imageRequest?.userGroupHash ?? fileRequest?.userGroupHash
        let uploadImage = imageRequest != nil
        let uploadPath = chat.config.spec.paths.podspace.upload
        let userGroupPath: String = uploadImage ? uploadPath.usergroupsImages : uploadPath.usergroupsFiles
        let normalPath: String = uploadImage ? uploadPath.images : uploadPath.files
        let path: String = userGroupHash != nil ? userGroupPath : normalPath
        let url = fileServer + path.replacingOccurrences(of: "{userGroupHash}", with: userGroupHash ?? "")
        return url
    }

    /// Upload by data.
    private func upload(_ req: UploadManagerParameters, _ data: Data, _ progressCompletion: UploadProgressType? = nil, _ completion: UploadCompletionType? = nil) {
        let uploadProgress: UploadProgressType = { [weak self] progress in
            Task {
                await self?.onUploadProgress(progress, req, progressCompletion)
            }
        }
        let delegate = ProgressImplementation(uniqueId: req.uniqueId, uploadProgress: uploadProgress)
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        let uploadManager = UploadManager()
        uploadManager.upload(req, data, session) { [weak self] respData, response, error in
            Task {
                await self?.onUploadCompleted(req, respData, error, data, completion)
            }
        }
        uploadManagers[req.uniqueId] = uploadManager
    }
    
    /// Upload by filePath.
    private func upload(_ req: UploadManagerParameters, _ progressCompletion: UploadProgressType? = nil, _ completion: UploadCompletionType? = nil) {
        let uploadManager = UploadManager()
        uploadManager.upload(req) { [weak self] progress in
            /// Progress completion
            Task {
                await self?.onUploadProgress(progress, req, progressCompletion)
            }
        } completion: { [weak self] data, response, error in
            /// On completionWith Error
            Task {
                await self?.onUploadCompleted(req, data, error, nil, completion)
            }
        }
        uploadManagers[req.uniqueId] = uploadManager
    }
    
    private func onUploadProgress(_ progress: UploadFileProgress?, _ req: UploadManagerParameters, _ progressCompletion: UploadProgressType? = nil) {
        delegate?.chatEvent(event: .upload(.progress(req.uniqueId, progress)))
        progressCompletion?(progress)
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

    private func onUploadCompleted(
        _ req: UploadManagerParameters,
        _ responseData: Data?,
        _ error: Error?,
        _ fileData: Data?,
        _ uploadCompletion: UploadCompletionType?
    ) {
        defer { removeTask(req.uniqueId) }
        
        if let error = uploadHasError(responseData, error) {
            delegate?.chatEvent(event: .upload(.failed(uniqueId: req.uniqueId, error: error)))
            return
        }
        
        guard
            let data = responseData,
            let uploadResponse = try? JSONDecoder.instance.decode(PodspaceFileUploadResponse.self, from: data)
        else {
            return
        }
        
        chat.logger.logJSON(
            title: "File uploaded successfully",
            jsonString: data.utf8StringOrEmpty,
            persist: false,
            type: .internalLog
        )
        
        let fileMetaData = uploadResponse.toMetaData(
            chat.config,
            width: req.imageRequest?.wC,
            height: req.imageRequest?.hC
        )
        
        handleFileSaveAndCallback(
            req: req,
            response: uploadResponse,
            fileMetaData: fileMetaData,
            responseData: data,
            fileData: fileData,
            uploadCompletion: uploadCompletion
        )
        
        cache?.deleteQueues(uniqueIds: [req.uniqueId])
    }
    
    private func handleFileSaveAndCallback(
        req: UploadManagerParameters,
        response: PodspaceFileUploadResponse,
        fileMetaData: FileMetaData?,
        responseData: Data,
        fileData: Data?,
        uploadCompletion: UploadCompletionType?
    ) {
        let complete = { @Sendable [weak self] in
            Task {
                uploadCompletion?(.init(response.result, fileMetaData, nil))
                await self?.delegate?.chatEvent(
                    event: .upload(.completed(
                        uniqueId: req.uniqueId,
                        fileMetaData: fileMetaData,
                        data: responseData,
                        error: nil
                    ))
                )
            }
        }

        guard chat.config.saveOnUpload == true else {
            complete()
            return
        }

        if let data = fileData {
            saveUploadedFile(req, response, data) { _ in
                Task { @ChatGlobalActor in complete() }
            }
        } else if let path = req.fileRequest?.filePath {
            saveUploadedFile(req, response, path) { _ in
                Task { @ChatGlobalActor in complete() }
            }
        } else {
            complete()
        }
    }

    private func saveUploadedFile(_ params: UploadManagerParameters,
                                  _ response: PodspaceFileUploadResponse,
                                  _ fileData: Data,
                                  _ saveCompletion: @escaping @Sendable (URL?) -> Void) {
        guard
            let hashCode = response.result?.hash,
            let url = serverURL(isImage: params.imageRequest != nil, responseHashCode: hashCode)
        else { return }
        fm?.saveFile(url: url, data: fileData, saveCompletion: saveCompletion)
    }
    
    private func saveUploadedFile(_ params: UploadManagerParameters,
                                  _ response: PodspaceFileUploadResponse,
                                  _ filePath: URL,
                                  _ saveCompletion: @escaping @Sendable (URL?) -> Void) {
        guard
            let hashCode = response.result?.hash,
            let url = serverURL(isImage: params.imageRequest != nil, responseHashCode: hashCode)
        else { return }
        fm?.moveAndSave(url: url, fromPath: filePath, saveCompletion: saveCompletion)
    }
    
    private func serverURL(isImage: Bool, responseHashCode: String) -> URL? {
        let config = chat.config
        let downloadPath = config.spec.paths.podspace.download
        let server = config.spec.server.file
        let path = isImage ? downloadPath.images : downloadPath.files
        return URL(string: "\(server)\(path)/\(responseHashCode)")
    }

    func manageUpload(uniqueId: String, action: DownloaUploadAction) {
        manageTask(upload: true, uniqueId: uniqueId, action: action)
    }

    func manageDownload(uniqueId: String, action: DownloaUploadAction) {
        manageTask(upload: false, uniqueId: uniqueId, action: action)
    }

    private func manageTask(upload: Bool, uniqueId: String, action: DownloaUploadAction) {
        let task = getTask(uniqueId: uniqueId)?.task
        switch action {
        case .cancel:
            task?.cancel()
            delegate?.chatEvent(event: upload ? .upload(.canceled(uniqueId: uniqueId)) : .download(.canceled(uniqueId: uniqueId)))
            removeTask(uniqueId)
            cache?.deleteQueues(uniqueIds: [uniqueId])
        case .suspend:
            task?.suspend()
            delegate?.chatEvent(event: upload ? .upload(.suspended(uniqueId: uniqueId)) : .download(.suspended(uniqueId: uniqueId)))
        case .resume:
            task?.resume()
            delegate?.chatEvent(event: upload ? .upload(.resumed(uniqueId: uniqueId)) : .download(.resumed(uniqueId: uniqueId)))
        }
    }

    public func get(_ request: ImageRequest) {
        if request.hashCode.isEmpty { return }
        let params = DownloadManagerParameters(request, chat.config, fm)
        download(params)
    }

    public func get(_ request: FileRequest) {
        if request.hashCode.isEmpty { return }
        let params = DownloadManagerParameters(request, chat.config, fm)
        download(params)
    }

    private func download(_ params: DownloadManagerParameters) {
        if params.forceToDownload {
            log("Start downloading with params:\n\(params.debugDescription)")
            let delegate = ProgressImplementation(uniqueId: params.uniqueId, uploadProgress: nil) { [weak self] progress in
                Task {
                    let progressEvent = ChatEventType.download(.progress(uniqueId: params.uniqueId, progress: progress))
                    await self?.onDownloadProgressCompletion(progressEvent)
                }
            } downloadCompletion: { [weak self] data, response, error in
                Task {
                    await self?.onDownloadCompletion(data, response, error, params)
                }
            }
            let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: .main)
            let task = DownloadManager.download(params, session)
            addTask(uniqueId: params.uniqueId, session: session, task: task)
        } else {
            Task {
                do {
                    log("Start fetching from cache with params:\n\(params.debugDescription)")
                    try await fetchFromCache(params)
                } catch {
                    log("Failed to find a cache for url: \(params.url.absoluteString)")
                    forceToDownloadIfCacheFailed(params)
                }
            }
        }
    }
    
    private func forceToDownloadIfCacheFailed(_ params: DownloadManagerParameters) {
        log("Start fetching from the server as a result of a cache failure:\n\(params.debugDescription)")
        var newParams = params
        newParams.forceToDownload = true
        download(newParams)
    }
    
    private func onDownloadProgressCompletion(_ event: ChatEventType) {
        delegate?.chatEvent(event: event)
    }
    
    private func onDownloadCompletion(_ data: Data?, _ response: URLResponse?, _ error: Error?, _ params: DownloadManagerParameters) async {
        log("Download completed with response:\(String(describing: response)) error:\(String(describing: error)) params:\n\(params.debugDescription)")
        await onDownload(params: params, data: data, response: response, error: error)
    }


    private func log(_ message: String) {
#if DEBUG
        chat.logger.log(title: "ChatFileManager", message: message, persist: false, type: .internalLog)
#endif
    }

    private func fetchFromCache(_ params: DownloadManagerParameters) async throws {
        guard let filePath = fm?.filePath(url: params.url),
              let _ = params.hashCode,
              fm?.isFileExist(url: params.url) == true || fm?.isFileExistInGroup(url: params.url) == true
        else { throw URLError(.fileDoesNotExist) }
        let data = await fm?.getData(url: params.url)
        let dataInGroup = await fm?.getDataInGroup(url: params.url)
        if let resultData = data ?? dataInGroup {
            let response = ChatResponse(uniqueId: params.uniqueId, result: resultData, cache: true, typeCode: nil)
            delegate?.chatEvent(event: .download(params.isImage ? .image(response, filePath) : .file(response, filePath)))
        } else {
            throw URLError(.fileDoesNotExist)
        }
    }

    func onDownload(params: DownloadManagerParameters, data: Data?, response: URLResponse?, error _: Error?) async {
        guard let response = response as? HTTPURLResponse,
              let headers = response.allHeaderFields as? [String: Sendable]
        else { return }
        let statusCode = response.statusCode
        if let errorResponse = handleDownloadError(statusCode, params, data, headers) {
            delegate?.chatEvent(event: .system(.error(errorResponse)))
            removeTask(params.uniqueId)
        } else if let data = data {
            if !params.thumbnail {
                let file = File(hashCode: params.hashCode ?? "", headers: headers)
                cache?.file?.insert(models: [file])
                guard let filePath = await fm?.saveFile(url: params.url, data: data) else { return }
                let response = ChatResponse(uniqueId: params.uniqueId, result: data, typeCode: nil)
                delegate?.chatEvent(event: .download(params.isImage ? .image(response, filePath) : .file(response, filePath)))
            } else {
                /// Is thumbnail and it does not need to save on the disk.
                let response = ChatResponse(uniqueId: params.uniqueId, result: data, typeCode: nil)
                delegate?.chatEvent(event: .download(params.isImage ? .image(response, nil) : .file(response, nil)))
            }
            removeTask(params.uniqueId)
        }
    }

    /// Delete a file in cache. with exact file url on the disk.
    func deleteCacheFile(_ url: URL) {
        fm?.deleteFile(at: url)
    }

    /// Return true if the file exist inside the sandbox of the ChatSDK application host.
    func isFileExist(_ url: URL) -> Bool {
        fm?.isFileExist(url: url) ?? false
    }

    /// Return the url of the file if it exists inside the sandbox of the ChatSDK application host.
    func filePath(_ url: URL) -> URL? {
        fm?.filePath(url: url)
    }

    /// Return the true of the file if it exists inside the share group.
    func isFileExistInGroup(_ url: URL) -> Bool {
        fm?.isFileExistInGroup(url: url) ?? false
    }

    /// Return the url of the file if it exists inside the share group.
    func filePathInGroup(_ url: URL) -> URL? {
        fm?.filePathInGroup(url: url)
    }

    /// Get data of a cache. file in the correspondent URL.
    func getData(_ url: URL, completion: @escaping @Sendable (Data?) -> Void) {
        fm?.getData(url: url) { data in
            completion(data)
        }
    }

    /// Get data of a cache. file in the correspondent URL inside a shared group.
    func getDataInGroup(_ url: URL, completion: @escaping @Sendable (Data?) -> Void) {
        fm?.getDataInGroup(url: url) { data in
            completion(data)
        }
    }

    /// Save a file inside the sandbox of the Chat SDK.
    func saveFile(url: URL, data: Data, completion: @escaping @Sendable (URL?) -> Void) {
        fm?.saveFile(url: url, data: data, saveCompletion: completion)
    }

    /// Save a file inside a shared group.
    func saveFileInGroup(url: URL, data: Data, completion: @escaping @Sendable (URL?) -> Void) {
        fm?.saveFileInGroup(url: url, data: data, saveCompletion: completion)
    }

    private func removeTask(_ uniqueId: String) {
        if let sessionandTask = tasks[uniqueId] {
            sessionandTask.session.invalidateAndCancel()
            tasks.removeValue(forKey: uniqueId)
            
        }
        if let uploadManager = uploadManagers[uniqueId] {
            uploadManager.cancelMultipart()
            uploadManager.session?.canelAndInvalidate()
            uploadManagers.removeValue(forKey: uniqueId)
        }
    }

    private func addTask(uniqueId: String, session: URLSession, task: URLSessionDataTaskProtocol?) {
        tasks[uniqueId] = (session, task)
    }
    
    private func getTask(uniqueId: String) -> SessionAndTask? {
        return tasks[uniqueId]
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
            Task {
                await self?.onTimerUserGroup(uniqueId: req.uniqueId)
            }
        }
    }
    
    private func onTimerUserGroup(uniqueId: String) {
        requests.removeValue(forKey: uniqueId)
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
    private func handleDownloadError(_ statusCode: Int, _ params: DownloadManagerParameters, _ data: Data?, _ headers: [String: Sendable]) -> ChatResponse<Sendable>? {
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

    private func unhandledError(_ params: DownloadManagerParameters, _ headers: [String: Sendable], _ typeCode: String) -> ChatResponse<Sendable>? {
        let message = (headers["errorMessage"] as? String) ?? ""
        let code = (headers["errorCode"] as? Int) ?? 999
        let error = ChatError(message: message, code: code, hasError: true, content: nil)
        return ChatResponse(uniqueId: params.uniqueId, error: error, typeCode: typeCode)
    }

    private func checkForAccessError(_ params: DownloadManagerParameters, _ typeCode: String) -> ChatResponse<Sendable>? {
        let error = ChatError(type: .notAddedInUserGroup, code: 403)
        handleUserGroupAccessError(params)
        return ChatResponse(uniqueId: params.uniqueId, error: error, typeCode: typeCode)
    }

    private func chatError(_ uniqueId: String, _ data: Data?, _ typeCode: String) -> ChatResponse<Sendable>? {
        if let data = data, let error = try? JSONDecoder.instance.decode(ChatError.self, from: data), error.hasError == true {
            return ChatResponse(uniqueId: uniqueId, error: error, typeCode: typeCode)
        }
        return nil
    }

    private func podspaceError(_ uniqueId: String?, _ data: Data?, _ typeCode: String) -> ChatResponse<Sendable>? {
        if let data = data, let podspaceError = try? JSONDecoder.instance.decode(PodspaceFileUploadResponse.self, from: data) {
            let error = ChatError(message: podspaceError.message, code: podspaceError.errorType?.rawValue, hasError: true)
            return ChatResponse(uniqueId: uniqueId, error: error, typeCode: typeCode)
        }
        return nil
    }
}

/// Resumable Dowloader
extension ChatFileManager {
    func download(_ request: ChatDTO.FileRequest) throws {
        try resumableDownlaodManager.download(request)
    }
    
    func pauseResumableDownload(hashCode: String) throws {
        try resumableDownlaodManager.pauseResumableDownload(hashCode: hashCode)
    }
    
    func resumeDownload(hashCode: String) throws {
        try resumableDownlaodManager.resumeDownloading(hashCode: hashCode)
    }
    
    func cancel(hashCode: String) throws {
        try resumableDownlaodManager.cancel(hashCode: hashCode)
    }
    
    func deleteResumableFile(hashCode: String) throws {
        try fm?.deleteResumeDataFile(hashCode: hashCode)
    }
}
