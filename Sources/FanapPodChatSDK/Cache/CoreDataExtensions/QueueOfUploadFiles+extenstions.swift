//
// QueueOfUploadFiles+extenstions.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public extension QueueOfUploadFiles {
    static let crud = CoreDataCrud<QueueOfUploadFiles>(entityName: "QueueOfUploadFiles")

    func getCodable() -> UploadFileRequest? {
        guard let fileData = dataToSend as Data? else { return nil }
        let uploadRequest = UploadFileRequest(data: fileData,
                                              fileExtension: fileExtension,
                                              fileName: fileName,
                                              mimeType: mimeType,
                                              originalName: originalName,
                                              userGroupHash: userGroupHash,
                                              uniqueId: uniqueId)
        return uploadRequest
    }

    class func convertFileToCM(request: UploadFileRequest, entity: QueueOfUploadFiles? = nil) -> QueueOfUploadFiles {
        let model = entity ?? QueueOfUploadFiles()

        model.dataToSend = request.data as NSData
        model.fileExtension = request.fileExtension
        model.fileName = request.fileName
        model.isPublic = request.isPublic as NSNumber?
        model.mimeType = request.mimeType
        model.originalName = request.originalName
        model.userGroupHash = request.userGroupHash
        model.typeCode = Chat.sharedInstance.config?.typeCode
        model.fileSize = request.fileSize as NSNumber?
        model.uniqueId = request.uniqueId

        return model
    }

    class func insert(request: UploadFileRequest, resultEntity: ((QueueOfUploadFiles) -> Void)? = nil) {
        if let entity = QueueOfUploadFiles.crud.find(keyWithFromat: "uniqueId == %@", value: request.uniqueId) {
            resultEntity?(entity)
            return
        }

        QueueOfUploadFiles.crud.insert { cmEntity in
            let cmEntity = convertFileToCM(request: request, entity: cmEntity)
            resultEntity?(cmEntity)
        }
    }
}
