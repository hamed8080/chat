//
//  CDQueueOfForwardMessages+CoreDataProperties.swift
//  ChatApplication
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation

public extension CDQueueOfForwardMessages {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDQueueOfForwardMessages> {
        NSFetchRequest<CDQueueOfForwardMessages>(entityName: "CDQueueOfForwardMessages")
    }

    @NSManaged var fromThreadId: NSNumber?
    @NSManaged var messageIds: String?
    @NSManaged var threadId: NSNumber?
    @NSManaged var typeCode: String?
    @NSManaged var uniqueIds: String?
}

public extension CDQueueOfForwardMessages {
    func update(_ queueOfForwardMessages: QueueOfForwardMessages) {
        fromThreadId = queueOfForwardMessages.fromThreadId as? NSNumber
        messageIds = queueOfForwardMessages.messageIds?.map { "\($0)" }.joined(separator: ",")
        threadId = queueOfForwardMessages.threadId as? NSNumber
        typeCode = queueOfForwardMessages.typeCode
        uniqueIds = queueOfForwardMessages.uniqueIds?.joined(separator: ",")
    }

    var codable: QueueOfForwardMessages {
        QueueOfForwardMessages(fromThreadId: fromThreadId?.intValue,
                               messageIds: messageIds?.split(separator: ",").compactMap { Int($0) },
                               threadId: threadId?.intValue,
                               typeCode: typeCode,
                               uniqueIds: uniqueIds?.split(separator: ",").map { String($0) })
    }
}
