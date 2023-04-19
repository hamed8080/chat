//
//  CDReplyInfo+CoreDataProperties.swift
//  Chat
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation
import ChatCore
import ChatModels

public extension CDReplyInfo {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDReplyInfo> {
        NSFetchRequest<CDReplyInfo>(entityName: "CDReplyInfo")
    }

    static let entityName = "CDReplyInfo"
    static func entityDescription(_ context: NSManagedObjectContext) -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }

    static func insertEntity(_ context: NSManagedObjectContext) -> CDReplyInfo {
        CDReplyInfo(entity: entityDescription(context), insertInto: context)
    }

    @NSManaged var markDeleted: NSNumber?
    @NSManaged var messageId: NSNumber?
    @NSManaged var messageText: String?
    @NSManaged var messageType: NSNumber?
    @NSManaged var metadata: String?
    @NSManaged var repliedToMessageId: NSNumber?
    @NSManaged var systemMetadata: String?
    @NSManaged var time: NSNumber?
    @NSManaged var parentMessage: CDMessage?
    @NSManaged var participant: CDParticipant?
}

public extension CDReplyInfo {
    func update(_ replyInfo: ReplyInfo) {
        markDeleted = replyInfo.deleted as? NSNumber
        messageText = replyInfo.message
        messageType = replyInfo.messageType?.rawValue as? NSNumber
        metadata = replyInfo.metadata
        repliedToMessageId = replyInfo.repliedToMessageId as? NSNumber
        systemMetadata = replyInfo.systemMetadata
        time = replyInfo.time as? NSNumber
    }

    var codable: ReplyInfo {
        ReplyInfo(deleted: markDeleted?.boolValue,
                  repliedToMessageId: repliedToMessageId?.intValue,
                  message: messageText,
                  messageType: MessageType(rawValue: messageType?.intValue ?? 0),
                  metadata: metadata,
                  systemMetadata: systemMetadata,
                  time: time?.uintValue,
                  participant: participant?.codable)
    }
}
