//
//  QueueOfForwardMessages+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class QueueOfForwardMessages: NSManagedObject {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fromThreadId = try container.decodeIfPresent(Int.self, forKey: .fromThreadId) as? NSNumber
        messageIds = try container.decodeIfPresent(String.self, forKey: .messageIds)
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        repliedTo = try container.decodeIfPresent(Int.self, forKey: .repliedTo) as? NSNumber
        threadId = try container.decodeIfPresent(Int.self, forKey: .threadId) as? NSNumber
        typeCode = try container.decodeIfPresent(String.self, forKey: .typeCode)
        uniqueIds = try container.decodeIfPresent(String.self, forKey: .uniqueIds)
    }
}

extension QueueOfForwardMessages {
    private enum CodingKeys: String, CodingKey {
        case fromThreadId
        case messageIds
        case metadata
        case repliedTo
        case threadId
        case typeCode
        case uniqueIds
    }

    convenience init(
        context: NSManagedObjectContext,
        fromThreadId: Int? = nil,
        messageIds: [Int]? = nil,
        metadata: String? = nil,
        repliedTo: Int? = nil,
        threadId: Int? = nil,
        typeCode: String? = nil,
        uniqueIds: String? = nil
    ) {
        self.init(context: context)
        self.fromThreadId = fromThreadId as? NSNumber
        self.messageIds = messageIds.map { "\($0)" }
        self.metadata = metadata
        self.repliedTo = repliedTo as? NSNumber
        self.threadId = threadId as? NSNumber
        self.typeCode = typeCode
        self.uniqueIds = uniqueIds
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(fromThreadId?.intValue, forKey: .fromThreadId)
        try container.encodeIfPresent(messageIds, forKey: .messageIds)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(repliedTo?.intValue, forKey: .repliedTo)
        try container.encodeIfPresent(threadId?.intValue, forKey: .threadId)
        try container.encodeIfPresent(typeCode, forKey: .typeCode)
        try container.encodeIfPresent(uniqueIds, forKey: .uniqueIds)
    }
}

// public extension QueueOfForwardMessages {
//    class func insert(request: ForwardMessageRequest, resultEntity: ((QueueOfForwardMessages) -> Void)? = nil) {
//        if let entity = QueueOfForwardMessages.crud.find(keyWithFromat: "uniqueIds == %@", value: request.uniqueId) {
//            resultEntity?(entity)
//        } else {
//            QueueOfForwardMessages.crud.insert { cmEntity in
//                let cmEntity = convertToCM(request: request, messageIds: request.messageIds, entity: cmEntity)
//                resultEntity?(cmEntity)
//            }
//        }
//    }
// }
