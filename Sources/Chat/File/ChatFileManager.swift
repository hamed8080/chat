//
// ChatFileManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation
import ChatCache

final class ChatFileManager: InternalFileProtocol {
    let chat: ChatInternalProtocol
    var delegate: ChatDelegate? { chat.delegate }
    var cache: CacheManager? { chat.cache }

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func upload(_ request: UploadImageRequest) {
        upload(request, nil)
    }

    func upload(_ request: UploadImageRequest, _ progressCompletion: UploadFileProgressType? = nil, _ uploadCompletion: UploadCompletionType? = nil) {
        let imagePath: Routes = request.userGroupHash != nil ? .uploadImageWithUserGroup : .images
        let url = chat.config.fileServer + imagePath.rawValue.replacingOccurrences(of: "{userGroupHash}", with: request.userGroupHash ?? "")
        guard let parameters = try? request.asDictionary() else { return }
        let headers = ["Authorization": "Bearer \(chat.config.token)", "Content-type": "multipart/form-data"]
        UploadManager(chat: chat)
            .upload(url: url,
                    headers: headers,
                    parameters: parameters,
                    fileData: request.data,
                    fileName: request.fileName,
                    mimetype: request.mimeType,
                    uniqueId: request.chatUniqueId,
                    uploadProgress: progressCompletion
            ) { [weak self] data, _, error in
            self?.onResponseUploadImage(request, data, error, uploadCompletion)
        }
    }

    func onResponseUploadImage(_ req: UploadImageRequest, _ data: Data?, _ error: Error?, _ uploadCompletion: UploadCompletionType?) {
        if let data = data, let chatError = try? JSONDecoder.instance.decode(ChatError.self, from: data), chatError.hasError == true {
            uploadCompletion?(nil, nil, chatError)
        } else if let data = data, let uploadResponse = try? JSONDecoder.instance.decode(PodspaceFileUploadResponse.self, from: data) {
            if uploadResponse.error != nil {
                let error = ChatError(message: "\(uploadResponse.error ?? "") - \(uploadResponse.message ?? "")", code: uploadResponse.errorType?.rawValue, hasError: true)
                uploadCompletion?(nil, nil, error)
                let response: ChatResponse<String> = .init(uniqueId: req.uniqueId, error: error)
                delegate?.chatEvent(event: .file(.uploadError(response)))
                return
            }
            chat.logger.logJSON(title: "Image uploaded successfully", jsonString: data.utf8StringOrEmpty, persist: false, type: .internalLog)
            let link = "\(chat.config.fileServer)\(Routes.images.rawValue)/\(uploadResponse.result?.hash ?? "")"
            let fileDetail = FileDetail(fileExtension: req.fileExtension,
                                        link: link,
                                        mimeType: req.mimeType,
                                        name: req.fileName,
                                        originalName: req.originalName,
                                        size: req.fileSize,
                                        fileHash: uploadResponse.result?.hash,
                                        hashCode: uploadResponse.result?.hash,
                                        parentHash: uploadResponse.result?.parentHash,
                                        actualHeight: req.hC,
                                        actualWidth: req.wC)
            let fileMetaData = FileMetaData(file: fileDetail, fileHash: uploadResponse.result?.hash, hashCode: uploadResponse.result?.hash, name: uploadResponse.result?.name)
            uploadCompletion?(uploadResponse.result, fileMetaData, nil)
            cache?.deleteQueues(uniqueIds: [req.chatUniqueId])
            let response: ChatResponse<String> = .init(uniqueId: req.uniqueId, result: req.uniqueId)
            delegate?.chatEvent(event: .file(.uploaded(response)))
        } else if let error = error {
            let error = ChatError(message: "\(ChatErrorType.networkError.rawValue) \(error)", code: 6200, hasError: true)
            uploadCompletion?(nil, nil, error)
            let response: ChatResponse<String> = .init(uniqueId: req.uniqueId, error: error)
            delegate?.chatEvent(event: .file(.uploadError(response)))
        }
    }

    func upload(_ request: UploadFileRequest) {
        upload(request, nil, nil)
    }

    func upload(_ request: UploadFileRequest, _ progressCompletion: UploadFileProgressType? = nil, _ uploadCompletion: UploadCompletionType? = nil) {
        let filePath: Routes = request.userGroupHash != nil ? .uploadFileWithUserGroup : .files
        let url = chat.config.fileServer + filePath.rawValue.replacingOccurrences(of: "{userGroupHash}", with: request.userGroupHash ?? "")
        guard let parameters = try? request.asDictionary() else { return }
        let headers = ["Authorization": "Bearer \(chat.config.token)", "Content-type": "multipart/form-data"]
        UploadManager(chat: chat)
            .upload(url: url,
                    headers: headers,
                    parameters: parameters,
                    fileData: request.data,
                    fileName: request.fileName,
                    mimetype: request.mimeType,
                    uniqueId: request.chatUniqueId) { [weak self] progress, error in
                progressCompletion?(progress, error)
                self?.delegate?.chatEvent(event: .file(.uploadProgress(request.uniqueId, progress, error)))
            } completion: { [weak self] data, _, error in
                self?.chat.delegate?.chatEvent(event: .file(.uploadCompletion(uniqueId: request.uniqueId, data, error)))
                self?.onResponseUploadFile(request, data, error, uploadCompletion)
            }
    }


    func onResponseUploadFile(_ req: UploadFileRequest, _ data: Data?, _ error: Error?, _ uploadCompletion: UploadCompletionType?) {
        // completed upload file
        if let data = data, let chatError = try? JSONDecoder.instance.decode(ChatError.self, from: data), chatError.hasError == true {
            uploadCompletion?(nil, nil, chatError)
            let response: ChatResponse<String> = .init(uniqueId: req.uniqueId, result: req.uniqueId, error: chatError)
            delegate?.chatEvent(event: .file(.uploadError(response)))
        } else if let data = data, let uploadResponse = try? JSONDecoder.instance.decode(PodspaceFileUploadResponse.self, from: data) {
            chat.logger.log(title: "Response is:\(data.utf8StringOrEmpty)", persist: false, type: .internalLog)
            if uploadResponse.error != nil {
                let error = ChatError(message: "\(uploadResponse.error ?? "") - \(uploadResponse.message ?? "")", code: uploadResponse.errorType?.rawValue, hasError: true)
                uploadCompletion?(nil, nil, error)
                let response: ChatResponse<String> = .init(uniqueId: req.uniqueId, result: req.uniqueId, error: error)
                delegate?.chatEvent(event: .file(.uploadError(response)))
                return
            }
            chat.logger.logJSON(title: "File uploaded successfully", jsonString: data.utf8StringOrEmpty, persist: false, type: .internalLog)
            let link = "\(chat.config.fileServer)\(Routes.files.rawValue)/\(uploadResponse.result?.hash ?? "")"
            let fileDetail = FileDetail(fileExtension: req.fileExtension,
                                        link: link,
                                        mimeType: req.mimeType,
                                        name: req.fileName,
                                        originalName: req.originalName,
                                        size: req.fileSize,
                                        fileHash: uploadResponse.result?.hash,
                                        hashCode: uploadResponse.result?.hash,
                                        parentHash: uploadResponse.result?.parentHash)
            let fileMetaData = FileMetaData(file: fileDetail, fileHash: uploadResponse.result?.hash, hashCode: uploadResponse.result?.hash, name: uploadResponse.result?.name)
            uploadCompletion?(uploadResponse.result, fileMetaData, nil)
            let response: ChatResponse<String> = .init(uniqueId: req.uniqueId, result: req.uniqueId)
            delegate?.chatEvent(event: .file(.uploaded(response)))
            cache?.deleteQueues(uniqueIds: [req.chatUniqueId])
        } else if let error = error {
            let error = ChatError(message: "\(ChatErrorType.networkError.rawValue) \(error)", code: 6200, hasError: true)
            uploadCompletion?(nil, nil, error)
            let response: ChatResponse<String> = .init(uniqueId: req.uniqueId, result: req.uniqueId, error: error)
            delegate?.chatEvent(event: .file(.uploadError(response)))
        }
    }

    func send(_ textMessage: SendTextMessageRequest, _ imageRequest: UploadImageRequest) {
        var textMessage = SendTextMessageRequest(request: textMessage, uniqueId: imageRequest.chatUniqueId)
        cache?.fileQueue?.insert(models: [textMessage.queueOfFileMessages(imageRequest)])
        upload(imageRequest, nil) { [weak self] _, fileMetaData, error in
            // completed upload file
            if let error = error {
                let response = ChatResponse(uniqueId: imageRequest.uniqueId, result: Optional<Any>.none, error: error)
                self?.chat.delegate?.chatEvent(event: .system(.error(response)))
            } else {
                guard let stringMetaData = fileMetaData.jsonString else { return }
                textMessage.metadata = stringMetaData
                self?.chat.message.send(textMessage)
            }
        }
    }

    func send(_ textMessage: SendTextMessageRequest, _ fileRequest: UploadFileRequest) {
        var textMessage = SendTextMessageRequest(request: textMessage, uniqueId: fileRequest.chatUniqueId)
        cache?.fileQueue?.insert(models: [textMessage.queueOfFileMessages(fileRequest)])
        self.upload(fileRequest, nil) { [weak self] _, fileMetaData, error in
            // completed upload file
            if let error = error {
                let response = ChatResponse(uniqueId: fileRequest.uniqueId, result: Optional<Any>.none, error: error)
                self?.chat.delegate?.chatEvent(event: .system(.error(response)))
            } else {
                guard let stringMetaData = fileMetaData.jsonString else { return }
                textMessage.metadata = stringMetaData
                self?.chat.message.send(textMessage)
            }
        }
    }

    func reply(_ replyMessage: ReplyMessageRequest, _ uploadFile: UploadFileRequest) {
        send(replyMessage.sendTextMessageRequest, uploadFile)
    }

    func manageUpload(uniqueId: String, action: DownloaUploadAction) {
        if let task = chat.callbacksManager.getUploadTask(uniqueId: uniqueId) {
            switch action {
            case .cancel:
                task.cancel()
                chat.callbacksManager.removeUploadTask(uniqueId: uniqueId)
                delegate?.chatEvent(event: .file(.canceledDownload(uniqueId: uniqueId)))
                cache?.deleteQueues(uniqueIds: [uniqueId])
            case .suspend:
                task.suspend()
                delegate?.chatEvent(event: .file(.suspendedDownload(uniqueId: uniqueId)))
            case .resume:
                task.resume()
                delegate?.chatEvent(event: .file(.resumedDownload(uniqueId: uniqueId)))
            }
        } else {
            delegate?.chatEvent(event: .file(.failed(uniqueId: uniqueId)))
        }
    }

    func manageDownload(uniqueId: String, action: DownloaUploadAction) {
        if let task = chat.callbacksManager.getDownloadTask(uniqueId: uniqueId) {
            switch action {
            case .cancel:
                task.cancel()
                delegate?.chatEvent(event: .file(.canceledUpload(uniqueId: uniqueId)))
                chat.callbacksManager.removeDownloadTask(uniqueId: uniqueId)
            case .suspend:
                task.suspend()
                delegate?.chatEvent(event: .file(.suspendedUpload(uniqueId: uniqueId)))
            case .resume:
                task.resume()
                delegate?.chatEvent(event: .file(.resumedUpload(uniqueId: uniqueId)))
            }
        } else {
            delegate?.chatEvent(event: .file(.failed(uniqueId: uniqueId)))
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
            DownloadManager(chat: chat)
                .download(url: url,
                          uniqueId: request.chatUniqueId,
                          headers: headers,
                          parameters: try? request.asDictionary())
            { [weak self] progress in
                self?.delegate?.chatEvent(event: .file(.downloadProgress(uniqueId: request.uniqueId, progress: progress)))
            } completion: { [weak self] (data, response, error) in
                self?.onDownload(hashCode: request.hashCode, uniqueId: request.uniqueId, url: url, data: data, response: response, error: error, isImage: true)
            }
        }

        if let filePath = chat.cacheFileManager?.filePath(url: URL(string: url)!) {
            cache?.image?.first(hashCode: request.hashCode) { [weak self] image in
                self?.chat.responseQueue.async {
                    let data = self?.chat.cacheFileManager?.getData(url: filePath) ?? self?.chat.cacheFileManager?.getDataInGroup(url: filePath)
                    let response = ChatResponse(uniqueId: request.uniqueId, result: data)
                    self?.delegate?.chatEvent(event: .file(.imageDownloaded(response, filePath)))
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
            DownloadManager(chat: chat)
                .download(url: url,
                          uniqueId: request.chatUniqueId,
                          headers: headers,
                          parameters: try? request.asDictionary())
            { [weak self] progress in
                self?.delegate?.chatEvent(event: .file(.downloadProgress(uniqueId: request.uniqueId, progress: progress)))
            } completion: { [weak self] (data, response, error) in
                self?.onDownload(hashCode: request.hashCode, uniqueId: request.uniqueId, url: url, data: data, response: response, error: error)
            }
        }

        if let filePath = chat.cacheFileManager?.filePath(url: URL(string: url)!) {
            cache?.file?.first(hashCode: request.hashCode) { [weak self] file in
                self?.chat.responseQueue.async {
                    let data = self?.chat.cacheFileManager?.getData(url: filePath) ?? self?.chat.cacheFileManager?.getDataInGroup(url: filePath)
                    let response = ChatResponse(uniqueId: request.uniqueId, result: data)
                    self?.delegate?.chatEvent(event: .file(.fileDownloaded(response, filePath)))
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
                self?.delegate?.chatEvent(event: .file( isImage ? .imageDownloaded(response, filePath) : .fileDownloaded(response, filePath)))
            }
        }
    }

    private func error(statusCode: Int, data: Data?, uniqueId: String, headers: [String: Any]) -> ChatResponse<Any>? {
        if statusCode >= 200 && statusCode <= 300 {
            if let data = data, let error = try? JSONDecoder.instance.decode(ChatError.self, from: data), error.hasError == true {
                let response = ChatResponse(uniqueId: uniqueId, result: Optional<Any>.none, error: error)
                return response
            }
            if let data = data, let podspaceError = try? JSONDecoder.instance.decode(PodspaceFileUploadResponse.self, from: data) {
                let error = ChatError(message: podspaceError.message, code: podspaceError.errorType?.rawValue, hasError: true)
                let response = ChatResponse(uniqueId: uniqueId, result: Optional<Any>.none, error: error)
                return response
            }
            return nil /// Means the result was success.
        } else {
            let message = (headers["errorMessage"] as? String) ?? ""
            let code = (headers["errorCode"] as? Int) ?? 999
            let error = ChatError(message: message, code: code, hasError: true, content: nil)
            let response = ChatResponse(uniqueId: uniqueId, result: Optional<Any>.none, error: error)
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

}
