//
//  CDQueueOfEditMessages+CoreDataProperties.swift
//  Chat
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation
import ChatCore
import ChatModels

public extension CDQueueOfEditMessages {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDQueueOfEditMessages> {
        NSFetchRequest<CDQueueOfEditMessages>(entityName: "CDQueueOfEditMessages")
    }

    static let entityName = "CDQueueOfEditMessages"
    static func entityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }

    static func insertEntity(_ context: NSManagedObjectContext) -> CDQueueOfEditMessages {
        CDQueueOfEditMessages(entity: entityDescription(context), insertInto: context)
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
