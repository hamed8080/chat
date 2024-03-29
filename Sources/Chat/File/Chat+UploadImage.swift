//
// Chat+UploadImage.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatCore
import ChatDTO
import ChatModels
import Foundation

extension Chat {
    /// Upload an image.
    /// - Parameters:
    ///   - req: The request that contains the data of an image and other image properties.
    ///   - uploadUniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    ///   - uploadProgress: The progress of uploading the image.
    ///   - uploadCompletion: The result shows whether the upload was successful or not.
    public func uploadImage(_ request: UploadImageRequest,
                            uploadUniqueIdResult: UniqueIdResultType? = nil,
                            uploadProgress: UploadFileProgressType? = nil,
                            uploadCompletion: UploadCompletionType? = nil)
    {
        uploadUniqueIdResult?(request.chatUniqueId)
        let imagePath: Routes = request.userGroupHash != nil ? .uploadImageWithUserGroup : .images
        let url = config.fileServer + imagePath.rawValue.replacingOccurrences(of: "{userGroupHash}", with: request.userGroupHash ?? "")
        guard let parameters = try? request.asDictionary() else { return }
        let headers = ["Authorization": "Bearer \(config.token)", "Content-type": "multipart/form-data"]
        UploadManager(callbackManager: callbacksManager).upload(url: url,
                                                                headers: headers,
                                                                parameters: parameters,
                                                                fileData: request.data,
                                                                fileName: request.fileName,
                                                                mimetype: request.mimeType,
                                                                uniqueId: request.chatUniqueId,
                                                                uploadProgress: uploadProgress) { [weak self] data, _, error in
            self?.onResponseUploadImage(req: request, data: data, error: error, uploadCompletion: uploadCompletion)
        }
    }

    func onResponseUploadImage(req: UploadImageRequest, data: Data?, error: Error?, uploadCompletion: UploadCompletionType?) {
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
            logger.logJSON(title: "Image uploaded successfully", jsonString: data.utf8StringOrEmpty, persist: false, type: .internalLog)
            let link = "\(config.fileServer)\(Routes.images.rawValue)/\(uploadResponse.result?.hash ?? "")"
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
}
