//
//  QueueOfFileMessages+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class QueueOfFileMessages: NSManagedObject {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fileExtension = try container.decodeIfPresent(String.self, forKey: .fileExtension)
        fileName = try container.decodeIfPresent(String.self, forKey: .fileName)
        fileToSend = try container.decodeIfPresent(Data.self, forKey: .fileToSend)
        imageToSend = try container.decodeIfPresent(Data.self, forKey: .imageToSend)
        isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic) as? NSNumber
        messageType = try container.decodeIfPresent(Int.self, forKey: .messageType) as? NSNumber
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        mimeType = try container.decodeIfPresent(String.self, forKey: .mimeType)
        originalName = try container.decodeIfPresent(String.self, forKey: .originalName)
        repliedTo = try container.decodeIfPresent(Int.self, forKey: .repliedTo) as? NSNumber
        textMessage = try container.decodeIfPresent(String.self, forKey: .textMessage)
        threadId = try container.decodeIfPresent(Int.self, forKey: .threadId) as? NSNumber
        typeCode = try container.decodeIfPresent(String.self, forKey: .typeCode)
        uniqueId = try container.decodeIfPresent(String.self, forKey: .uniqueId)
        userGroupHash = try container.decodeIfPresent(String.self, forKey: .userGroupHash)
        hC = try container.decodeIfPresent(Int.self, forKey: .hC) as? NSNumber
        wC = try container.decodeIfPresent(Int.self, forKey: .wC) as? NSNumber
        xC = try container.decodeIfPresent(Int.self, forKey: .xC) as? NSNumber
        yC = try container.decodeIfPresent(Int.self, forKey: .yC) as? NSNumber
    }
}

extension QueueOfFileMessages {
    private enum CodingKeys: String, CodingKey {
        case fileExtension
        case fileName
        case fileToSend
        case hC
        case imageToSend
        case isPublic
        case messageType
        case metadata
        case mimeType
        case originalName
        case repliedTo
        case textMessage
        case threadId
        case typeCode
        case uniqueId
        case userGroupHash
        case wC
        case xC
        case yC
    }

    convenience init(
        context: NSManagedObjectContext,
        fileExtension: String? = nil,
        fileName: String? = nil,
        isPublic: Bool? = nil,
        messageType: MessageType? = nil,
        metadata: String? = nil,
        mimeType: String? = nil,
        originalName: String? = nil,
        repliedTo: Int? = nil,
        textMessage: String? = nil,
        threadId: Int? = nil,
        typeCode: String? = nil,
        uniqueId: String? = nil,
        userGroupHash: String? = nil,
        hC: Int? = nil,
        wC: Int? = nil,
        xC: Int? = nil,
        yC: Int? = nil
    ) {
        self.init(context: context)
        self.fileExtension = fileExtension
        self.fileName = fileName
        self.isPublic = isPublic as? NSNumber
        self.messageType = messageType?.rawValue as? NSNumber
        self.metadata = metadata
        self.mimeType = mimeType
        self.originalName = originalName
        self.repliedTo = repliedTo as? NSNumber
        self.textMessage = textMessage
        self.threadId = threadId as? NSNumber
        self.typeCode = typeCode
        self.uniqueId = uniqueId
        self.userGroupHash = userGroupHash
        self.hC = hC as? NSNumber
        self.wC = wC as? NSNumber
        self.xC = xC as? NSNumber
        self.yC = yC as? NSNumber
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(fileExtension, forKey: .fileExtension)
        try container.encodeIfPresent(fileName, forKey: .fileName)
        try container.encodeIfPresent(isPublic?.boolValue, forKey: .isPublic)
        try container.encodeIfPresent(messageType?.intValue, forKey: .messageType)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(mimeType, forKey: .mimeType)
        try container.encodeIfPresent(originalName, forKey: .originalName)
        try container.encodeIfPresent(repliedTo?.intValue, forKey: .repliedTo)
        try container.encodeIfPresent(textMessage, forKey: .textMessage)
        try container.encodeIfPresent(threadId?.intValue, forKey: .threadId)
        try container.encodeIfPresent(typeCode, forKey: .typeCode)
        try container.encodeIfPresent(uniqueId, forKey: .uniqueId)
        try container.encodeIfPresent(userGroupHash, forKey: .userGroupHash)
        try container.encodeIfPresent(hC?.intValue, forKey: .hC)
        try container.encodeIfPresent(wC?.intValue, forKey: .wC)
        try container.encodeIfPresent(xC?.intValue, forKey: .xC)
        try container.encodeIfPresent(yC?.intValue, forKey: .yC)
    }
}

// public extension QueueOfFileMessages {
//    static let crud = CoreDataCrud<QueueOfFileMessages>(entityName: "QueueOfFileMessages")
//
//    func getCodable() -> (UploadFileRequest, SendTextMessageRequest)? {
//        guard let threadId = threadId as? Int, let textMessage = textMessage, let messageType = messageType as? Int else { return nil }
//        let textMessageRequest = SendTextMessageRequest(threadId: threadId, textMessage: textMessage, messageType: MessageType(rawValue: messageType) ?? .podSpaceFile)
//
//        if let imageData = imageToSend as Data? {
//            // is image upload file
//            let uploadRequest = UploadImageRequest(data: imageData,
//                                                   xC: (xC as? Int) ?? 0,
//                                                   yC: (yC as? Int) ?? 0,
//                                                   hC: (hC as? Int) ?? 0,
//                                                   wC: (wC as? Int) ?? 0,
//                                                   fileExtension: fileExtension,
//                                                   fileName: fileName,
//                                                   mimeType: mimeType,
//                                                   originalName: originalName,
//                                                   userGroupHash: userGroupHash,
//                                                   uniqueId: uniqueId)
//            return (uploadRequest, textMessageRequest)
//        } else {
//            // any file upload
//            guard let fileData = fileToSend as Data? else { return nil }
//            let uploadRequest = UploadFileRequest(data: fileData,
//                                                  fileExtension: fileExtension,
//                                                  fileName: fileName,
//                                                  mimeType: mimeType,
//                                                  originalName: originalName,
//                                                  userGroupHash: userGroupHash,
//                                                  uniqueId: uniqueId)
//            return (uploadRequest, textMessageRequest)
//        }
//    }
//
//    class func convertFileToCM(request: UploadFileRequest, textMessage: SendTextMessageRequest? = nil, entity: QueueOfFileMessages? = nil) -> QueueOfFileMessages {
//        let model = entity ?? QueueOfFileMessages()
//
//        if let textMessage = textMessage {
//            model.textMessage = textMessage.textMessage
//            model.messageType = textMessage.messageType.rawValue as NSNumber?
//            model.metadata = textMessage.metadata
//            model.repliedTo = textMessage.repliedTo as NSNumber?
//            model.threadId = textMessage.threadId as NSNumber?
//            model.uniqueId = textMessage.uniqueId
//        }
//
//        model.imageToSend = request.data as NSData
//        model.fileExtension = request.fileExtension
//        model.fileName = request.fileName
//        model.isPublic = request.isPublic as NSNumber?
//        model.mimeType = request.mimeType
//        model.originalName = request.originalName
//        model.userGroupHash = request.userGroupHash
//        model.typeCode = request.typeCode
//
//        return model
//    }
//
//    class func convertImageToCM(request: UploadImageRequest, textMessage: SendTextMessageRequest? = nil, entity: QueueOfFileMessages? = nil) -> QueueOfFileMessages {
//        let model = entity ?? QueueOfFileMessages()
//
//        if let textMessage = textMessage {
//            model.textMessage = textMessage.textMessage
//            model.messageType = textMessage.messageType.rawValue as NSNumber?
//            model.metadata = textMessage.metadata
//            model.repliedTo = textMessage.repliedTo as NSNumber?
//            model.threadId = textMessage.threadId as NSNumber?
//            model.uniqueId = textMessage.uniqueId
//        }
//
//        model.imageToSend = request.data as NSData
//        model.fileExtension = request.fileExtension
//        model.fileName = request.fileName
//        model.isPublic = request.isPublic as NSNumber?
//        model.mimeType = request.mimeType
//        model.originalName = request.originalName
//        model.userGroupHash = request.userGroupHash
//        model.xC = request.xC as NSNumber?
//        model.yC = request.yC as NSNumber?
//        model.hC = request.hC as NSNumber?
//        model.wC = request.wC as NSNumber?
//        model.typeCode = request.typeCode
//
//        return model
//    }
//
//    class func insert(request: UploadFileRequest, textMessage: SendTextMessageRequest? = nil, resultEntity: ((QueueOfFileMessages) -> Void)? = nil) {
//        if let entity = QueueOfFileMessages.crud.find(keyWithFromat: "uniqueId == %@", value: request.uniqueId) {
//            resultEntity?(entity)
//            return
//        }
//        if let imageRequest = request as? UploadImageRequest {
//            QueueOfFileMessages.crud.insert { cmEntity in
//                let cmEntity = convertImageToCM(request: imageRequest, textMessage: textMessage, entity: cmEntity)
//                resultEntity?(cmEntity)
//            }
//        } else {
//            QueueOfFileMessages.crud.insert { cmEntity in
//                let cmEntity = convertFileToCM(request: request, textMessage: textMessage, entity: cmEntity)
//                resultEntity?(cmEntity)
//            }
//        }
//    }
// }
