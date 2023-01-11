//
//  CDQueueOfEditMessages+CoreDataProperties.swift
//  ChatApplication
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation

public extension CDQueueOfEditMessages {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDQueueOfEditMessages> {
        NSFetchRequest<CDQueueOfEditMessages>(entityName: "CDQueueOfEditMessages")
    }

    @NSManaged var messageId: NSNumber?
    @NSManaged var messageType: NSNumber?
    @NSManaged var metadata: String?
    @NSManaged var repliedTo: NSNumber?
    @NSManaged var textMessage: String?
    @NSManaged var threadId: NSNumber?
    @NSManaged var typeCode: String?
    @NSManaged var uniqueId: String?
}

public extension CDQueueOfEditMessages {
    func update(_ queueOfEditMessages: QueueOfEditMessages) {
        messageId = queueOfEditMessages.messageId as? NSNumber
        messageType = queueOfEditMessages.messageType?.rawValue as? NSNumber
        metadata = queueOfEditMessages.metadata
        repliedTo = queueOfEditMessages.repliedTo as? NSNumber
        textMessage = queueOfEditMessages.textMessage
        threadId = queueOfEditMessages.threadId as? NSNumber
        typeCode = queueOfEditMessages.typeCode
        uniqueId = queueOfEditMessages.uniqueId
    }

    var codable: QueueOfEditMessages {
        QueueOfEditMessages(messageId: messageId?.intValue,
                            messageType: MessageType(rawValue: messageType?.intValue ?? 0),
                            metadata: metadata,
                            repliedTo: repliedTo?.intValue,
                            textMessage: textMessage,
                            threadId: threadId?.intValue,
                            typeCode: typeCode,
                            uniqueId: uniqueId)
    }
}
