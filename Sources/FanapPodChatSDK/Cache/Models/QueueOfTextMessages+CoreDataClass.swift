//
//  QueueOfTextMessages+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class QueueOfTextMessages: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messageType = try container.decodeIfPresent(Int.self, forKey: .messageType) as? NSNumber
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        repliedTo = try container.decodeIfPresent(Int.self, forKey: .repliedTo) as? NSNumber
        systemMetadata = try container.decodeIfPresent(String.self, forKey: .systemMetadata)
        textMessage = try container.decodeIfPresent(String.self, forKey: .textMessage)
        threadId = try container.decodeIfPresent(Int.self, forKey: .threadId) as? NSNumber
        typeCode = try container.decodeIfPresent(String.self, forKey: .typeCode)
        uniqueId = try container.decodeIfPresent(String.self, forKey: .uniqueId)
    }
}

extension QueueOfTextMessages {
    private enum CodingKeys: String, CodingKey {
        case messageType
        case metadata
        case repliedTo
        case systemMetadata
        case textMessage
        case threadId
        case typeCode
        case uniqueId
    }

    convenience init(
        context: NSManagedObjectContext,
        messageType: MessageType? = nil,
        metadata: String? = nil,
        repliedTo: Int? = nil,
        systemMetadata: String? = nil,
        textMessage: String? = nil,
        threadId: Int? = nil,
        typeCode: String? = nil,
        uniqueId: String? = nil
    ) {
        self.init(context: context)
        self.messageType = messageType?.rawValue as? NSNumber
        self.metadata = metadata
        self.repliedTo = repliedTo as? NSNumber
        self.systemMetadata = systemMetadata
        self.textMessage = textMessage
        self.threadId = threadId as? NSNumber
        self.typeCode = typeCode
        self.uniqueId = uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(messageType?.intValue, forKey: .messageType)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(repliedTo?.intValue, forKey: .repliedTo)
        try container.encodeIfPresent(systemMetadata, forKey: .systemMetadata)
        try container.encodeIfPresent(textMessage, forKey: .textMessage)
        try container.encodeIfPresent(threadId?.intValue, forKey: .threadId)
        try container.encodeIfPresent(typeCode, forKey: .typeCode)
        try container.encodeIfPresent(uniqueId, forKey: .uniqueId)
    }
}

//
// public extension QueueOfTextMessages {
//    class func insert(request: SendTextMessageRequest, resultEntity: ((QueueOfTextMessages) -> Void)? = nil) {
//        if let entity = QueueOfTextMessages.crud.find(keyWithFromat: "uniqueId == %@", value: request.uniqueId) {
//            resultEntity?(entity)
//            return
//        }
//        QueueOfTextMessages.crud.insert { cmEntity in
//            let cmEntity = convertToCM(request: request, entity: cmEntity)
//            resultEntity?(cmEntity)
//        }
//    }
// }
