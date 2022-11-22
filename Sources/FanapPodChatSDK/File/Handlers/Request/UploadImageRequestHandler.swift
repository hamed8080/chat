//
// UploadImageRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class UploadImageRequestHandler {
    class func uploadImage(_ chat: Chat,
                           _ req: UploadImageRequest,
                           _ uploadCompletion: UploadCompletionType? = nil,
                           _ uploadProgress: UploadFileProgressType? = nil,
                           _ uploadUniqueIdResult: UniqueIdResultType? = nil)
    {
        uploadUniqueIdResult?(req.uniqueId)
        let chatDelegate = Chat.sharedInstance.delegate

        guard let fileServer = chat.config?.fileServer else { return }
        let imagePath: Routes = req.userGroupHash != nil ? .uploadImageWithUserGroup : .images
        let url = fileServer + imagePath.rawValue.replacingOccurrences(of: "{userGroupHash}", with: req.userGroupHash ?? "")
        guard let token = chat.config?.token, let parameters = try? req.asDictionary() else { return }
        let headers = ["Authorization": "Bearer \(token)", "Content-type": "multipart/form-data"]

        CacheFactory.write(cacheType: .deleteQueue(req.uniqueId))
        CacheFactory.save()

        UploadManager.upload(url: url,
                             headers: headers,
                             parameters: parameters,
                             fileData: req.data,
                             fileName: req.fileName,
                             mimetype: req.mimeType,
                             uniqueId: req.uniqueId,
                             uploadProgress: uploadProgress) { data, _, error in
            if let data = data, let chatError = try? JSONDecoder().decode(ChatError.self, from: data), chatError.hasError == true {
                uploadCompletion?(nil, nil, chatError)
            } else if let data = data, let uploadResponse = try? JSONDecoder().decode(PodspaceFileUploadResponse.self, from: data) {
                if uploadResponse.error != nil {
                    let error = ChatError(message: "\(uploadResponse.error ?? "") - \(uploadResponse.message ?? "")", errorCode: uploadResponse.errorType?.rawValue, hasError: true)
                    uploadCompletion?(nil, nil, error)
                    chatDelegate?.chatEvent(event: .file(.uploadError(error)))
                    return
                }
                if FanapPodChatSDK.Chat.sharedInstance.config?.isDebuggingLogEnabled == true {
                    Chat.sharedInstance.logger?.log(title: "file uploaded successfully", message: "\(String(data: data, encoding: .utf8) ?? "")")
                }
                let link = "\(fileServer)\(Routes.images.rawValue)/\(uploadResponse.result?.hash ?? "")"
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
                CacheFactory.write(cacheType: .deleteQueue(req.uniqueId))
                CacheFactory.save()
                chatDelegate?.chatEvent(event: .file(.uploaded(req)))
            } else if let error = error {
                let error = ChatError(message: "\(ChatErrorCodes.networkError.rawValue) \(error)", errorCode: 6200, hasError: true)
                uploadCompletion?(nil, nil, error)
                chatDelegate?.chatEvent(event: .file(.uploadError(error)))
            }
        }
    }
}
