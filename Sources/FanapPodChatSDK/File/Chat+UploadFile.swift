//
// Chat+UploadFile.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

extension Chat {
    func requestUploadFile(
        _ req: UploadFileRequest,
        _ uploadCompletion: UploadCompletionType?,
        _ uploadProgress: UploadFileProgressType? = nil,
        _ uploadUniqueIdResult: UniqueIdResultType? = nil
    ) {
        uploadUniqueIdResult?(req.uniqueId)
        let filePath: Routes = req.userGroupHash != nil ? .uploadFileWithUserGroup : .files
        let url = config.fileServer + filePath.rawValue.replacingOccurrences(of: "{userGroupHash}", with: req.userGroupHash ?? "")
        guard let parameters = try? req.asDictionary() else { return }
        let headers = ["Authorization": "Bearer \(config.token)", "Content-type": "multipart/form-data"]

        cache.write(cacheType: .deleteQueue(req.uniqueId))
        cache.save()

        UploadManager(callbackManager: callbacksManager)
            .upload(url: url,
                    headers: headers,
                    parameters: parameters,
                    fileData: req.data,
                    fileName: req.fileName,
                    mimetype: req.mimeType,
                    uniqueId: req.uniqueId,
                    uploadProgress: uploadProgress) { [weak self] data, _, error in
                self?.onResponseUploadFile(req: req, data: data, error: error, uploadCompletion: uploadCompletion)
            }
    }

    func onResponseUploadFile(req: UploadFileRequest, data: Data?, error: Error?, uploadCompletion: UploadCompletionType?) {
        // completed upload file
        if let data = data, let chatError = try? JSONDecoder().decode(ChatError.self, from: data), chatError.hasError == true {
            uploadCompletion?(nil, nil, chatError)
            delegate?.chatEvent(event: .file(.uploadError(chatError)))
        } else if let data = data, let uploadResponse = try? JSONDecoder().decode(PodspaceFileUploadResponse.self, from: data) {
            logger?.log(title: "response is:\(String(data: data, encoding: .utf8) ?? "") ")
            if uploadResponse.error != nil {
                let error = ChatError(message: "\(uploadResponse.error ?? "") - \(uploadResponse.message ?? "")", errorCode: uploadResponse.errorType?.rawValue, hasError: true)
                uploadCompletion?(nil, nil, error)
                delegate?.chatEvent(event: .file(.uploadError(error)))
                return
            }
            if config.isDebuggingLogEnabled == true {
                logger?.log(title: "file uploaded successfully", message: "\(String(data: data, encoding: .utf8) ?? "")")
            }
            let link = "\(config.fileServer)\(Routes.files.rawValue)/\(uploadResponse.result?.hash ?? "")"
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
            delegate?.chatEvent(event: .file(.uploaded(req)))
            cache.write(cacheType: .deleteQueue(req.uniqueId))
            cache.save()
        } else if let error = error {
            let error = ChatError(message: "\(ChatErrorCodes.networkError.rawValue) \(error)", errorCode: 6200, hasError: true)
            uploadCompletion?(nil, nil, error)
            delegate?.chatEvent(event: .file(.uploadError(error)))
        }
    }
}
