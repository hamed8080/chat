//
//  CDQueueOfTextMessages+CoreDataProperties.swift
//  ChatApplication
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation

public extension CDQueueOfTextMessages {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDQueueOfTextMessages> {
        NSFetchRequest<CDQueueOfTextMessages>(entityName: "CDQueueOfTextMessages")
    }

    @NSManaged var messageType: NSNumber?
    @NSManaged var metadata: String?
    @NSManaged var repliedTo: NSNumber?
    @NSManaged var systemMetadata: String?
    @NSManaged var textMessage: String?
    @NSManaged var threadId: NSNumber?
    @NSManaged var typeCode: String?
    @NSManaged var uniqueId: String?
}

public extension CDQueueOfTextMessages {
    func update(_ queueOfTextMessages: QueueOfTextMessages) {
        messageType = queueOfTextMessages.messageType?.rawValue as? NSNumber
        metadata = queueOfTextMessages.metadata
        repliedTo = queueOfTextMessages.repliedTo as? NSNumber
        systemMetadata = queueOfTextMessages.systemMetadata
        textMessage = queueOfTextMessages.textMessage
        threadId = queueOfTextMessages.threadId as? NSNumber
        typeCode = queueOfTextMessages.typeCode
        uniqueId = queueOfTextMessages.uniqueId
    }

    var codable: QueueOfTextMessages {
        QueueOfTextMessages(messageType: MessageType(rawValue: messageType?.intValue ?? 0),
                            metadata: metadata,
                            repliedTo: repliedTo?.intValue,
                            systemMetadata: systemMetadata,
                            textMessage: textMessage,
                            threadId: threadId?.intValue,
                            typeCode: typeCode,
                            uniqueId: uniqueId)
    }
}
