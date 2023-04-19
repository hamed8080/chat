//
//  CDQueueOfFileMessages+CoreDataProperties.swift
//  Chat
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation
import ChatModels
import ChatCore

public extension CDQueueOfFileMessages {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDQueueOfFileMessages> {
        NSFetchRequest<CDQueueOfFileMessages>(entityName: "CDQueueOfFileMessages")
    }

    static let entityName = "CDQueueOfFileMessages"
    static func entityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }

    static func insertEntity(_ context: NSManagedObjectContext) -> CDQueueOfFileMessages {
        CDQueueOfFileMessages(entity: entityDescription(context), insertInto: context)
    }

    @NSManaged var fileExtension: String?
    @NSManaged var fileName: String?
    @NSManaged var fileToSend: Data?
    @NSManaged var hC: NSNumber?
    @NSManaged var imageToSend: Data?
    @NSManaged var isPublic: NSNumber?
    @NSManaged var messageType: NSNumber?
    @NSManaged var metadata: String?
    @NSManaged var mimeType: String?
    @NSManaged var originalName: String?
    @NSManaged var repliedTo: NSNumber?
    @NSManaged var textMessage: String?
    @NSManaged var threadId: NSNumber?
    @NSManaged var typeCode: String?
    @NSManaged var uniqueId: String?
    @NSManaged var userGroupHash: String?
    @NSManaged var wC: NSNumber?
    @NSManaged var xC: NSNumber?
    @NSManaged var yC: NSNumber?
}

public extension CDQueueOfFileMessages {
    func update(_ queueOfFileMessages: QueueOfFileMessages) {
        fileExtension = queueOfFileMessages.fileExtension
        fileName = queueOfFileMessages.fileName
        fileToSend = queueOfFileMessages.fileToSend
        imageToSend = queueOfFileMessages.imageToSend
        isPublic = queueOfFileMessages.isPublic as? NSNumber
        messageType = queueOfFileMessages.messageType?.rawValue as? NSNumber
        metadata = queueOfFileMessages.metadata
        mimeType = queueOfFileMessages.mimeType
        originalName = queueOfFileMessages.originalName
        repliedTo = queueOfFileMessages.repliedTo as? NSNumber
        textMessage = queueOfFileMessages.textMessage
        threadId = queueOfFileMessages.threadId as? NSNumber
        typeCode = queueOfFileMessages.typeCode
        uniqueId = queueOfFileMessages.uniqueId
        userGroupHash = queueOfFileMessages.userGroupHash
        hC = queueOfFileMessages.hC as? NSNumber
        wC = queueOfFileMessages.wC as? NSNumber
        xC = queueOfFileMessages.xC as? NSNumber
        yC = queueOfFileMessages.yC as? NSNumber
    }

    var codable: QueueOfFileMessages {
        QueueOfFileMessages(fileExtension: fileExtension,
                            fileName: fileName,
                            isPublic: isPublic?.boolValue,
                            messageType: MessageType(rawValue: messageType?.intValue ?? 0),
                            metadata: metadata,
                            mimeType: mimeType,
                            originalName: originalName,
                            repliedTo: repliedTo?.intValue,
                            textMessage: textMessage,
                            threadId: threadId?.intValue,
                            typeCode: typeCode,
                            uniqueId: uniqueId,
                            userGroupHash: userGroupHash,
                            hC: hC?.intValue,
                            wC: wC?.intValue,
                            xC: xC?.intValue,
                            yC: yC?.intValue,
                            fileToSend: fileToSend,
                            imageToSend: imageToSend)
    }
}
