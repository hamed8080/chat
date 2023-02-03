//
//  CDMessage+CoreDataProperties.swift
//  ChatApplication
//
//  Created by hamed on 1/8/23.
//
//

import CoreData
import Foundation

public extension CDMessage {
    @nonobjc class func fetchRequest() -> NSFetchRequest<CDMessage> {
        NSFetchRequest<CDMessage>(entityName: "CDMessage")
    }

    @NSManaged var deletable: NSNumber?
    @NSManaged var delivered: NSNumber?
    @NSManaged var editable: NSNumber?
    @NSManaged var edited: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var mentioned: NSNumber?
    @NSManaged var message: String?
    @NSManaged var messageType: NSNumber?
    @NSManaged var metadata: String?
    @NSManaged var notifyAll: NSNumber?
    @NSManaged var ownerId: NSNumber?
    @NSManaged var pinned: NSNumber?
    @NSManaged var pinTime: NSNumber?
    @NSManaged var previousId: NSNumber?
    @NSManaged var seen: NSNumber?
    @NSManaged var systemMetadata: String?
    @NSManaged var threadId: NSNumber?
    @NSManaged var time: NSNumber?
    @NSManaged var uniqueId: String?
    @NSManaged var conversation: CDConversation?
    @NSManaged var forwardInfo: CDForwardInfo?
    @NSManaged var lastMessageVO: CDConversation?
    @NSManaged var participant: CDParticipant?
    @NSManaged var pinMessages: CDConversation?
    @NSManaged var replyInfo: CDReplyInfo?
}

public extension CDMessage {
    func update(_ message: Message) {
        deletable = message.deletable as? NSNumber
        delivered = message.delivered as? NSNumber
        editable = message.editable as? NSNumber
        edited = message.edited as? NSNumber
        id = message.id as? NSNumber
        mentioned = message.mentioned as? NSNumber
        self.message = message.message
        messageType = message.messageType?.rawValue as? NSNumber
        metadata = message.metadata
        ownerId = message.ownerId as? NSNumber
        pinned = message.pinned as? NSNumber
        previousId = message.previousId as? NSNumber
        seen = message.seen as? NSNumber
        systemMetadata = message.systemMetadata
        threadId = message.threadId as? NSNumber
        time = message.time as? NSNumber
        uniqueId = message.uniqueId
        pinTime = message.pinTime as? NSNumber
        notifyAll = message.pinNotifyAll as? NSNumber
    }

    func codable(fillConversation: Bool = true, fillParticipant: Bool = true) -> Message {
        Message(threadId: threadId?.intValue,
                deletable: deletable?.boolValue,
                delivered: deletable?.boolValue,
                editable: editable?.boolValue,
                edited: edited?.boolValue,
                id: id?.intValue,
                mentioned: mentioned?.boolValue,
                message: message,
                messageType: MessageType(rawValue: messageType?.intValue ?? 0),
                metadata: metadata,
                ownerId: ownerId?.intValue,
                pinned: pinned?.boolValue,
                previousId: previousId?.intValue,
                seen: seen?.boolValue,
                systemMetadata: systemMetadata,
                time: time?.uintValue,
                timeNanos: time?.uintValue,
                uniqueId: uniqueId,
                conversation: fillConversation ? conversation?.codable() : nil,
                forwardInfo: forwardInfo?.codable,
                participant: fillParticipant ? participant?.codable : nil,
                replyInfo: replyInfo?.codable,
                pinTime: pinTime?.uintValue,
                notifyAll: notifyAll?.boolValue)
    }
}
