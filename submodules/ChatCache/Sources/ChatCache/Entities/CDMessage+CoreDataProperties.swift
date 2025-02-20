//
// CDMessage+CoreDataProperties.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public extension CDMessage {
    typealias Entity = CDMessage
    typealias Model = Message
    typealias Id = NSNumber
    static let name = "CDMessage"
    static let queryIdSpecifier: String = "%@"
    static let idName = "id"
}

public extension CDMessage {
    @NSManaged var deletable: NSNumber?
    @NSManaged var delivered: NSNumber?
    @NSManaged var editable: NSNumber?
    @NSManaged var edited: NSNumber?
    /// Messages with the same ID cannot exist in two different threads since they are unique to the server.
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
    @NSManaged var forwardInfo: ForwardInfoClass?
    @NSManaged var conversationLastMessageVO: CDConversation?
    @NSManaged var participant: CDParticipant?
    @NSManaged var pinMessages: CDConversation?
    @NSManaged var replyInfo: ReplyInfoClass?
    @NSManaged var replyToMessageId: NSNumber?
    @NSManaged var callHistory: CallHistoryClass?
}

public extension CDMessage {
    func update(_ model: Model) {
        deletable = model.deletable as? NSNumber ?? deletable
        delivered = model.delivered as? NSNumber ?? delivered
        editable = model.editable as? NSNumber ?? editable
        edited = model.edited as? NSNumber ?? edited
        id = model.id as? NSNumber ?? id
        mentioned = model.mentioned as? NSNumber ?? mentioned
        message = model.message ?? message
        messageType = model.messageType?.rawValue as? NSNumber ?? messageType
        metadata = model.metadata ?? metadata
        ownerId = model.ownerId as? NSNumber ?? ownerId
        pinned = model.pinned as? NSNumber ?? pinned
        previousId = model.previousId as? NSNumber ?? previousId
        seen = model.seen as? NSNumber ?? seen
        systemMetadata = model.systemMetadata ?? systemMetadata
        threadId = model.threadId as? NSNumber ?? model.conversation?.id as? NSNumber ?? threadId
        time = model.time as? NSNumber ?? time
        uniqueId = model.uniqueId ?? uniqueId
        pinTime = model.pinTime as? NSNumber ?? pinTime
        notifyAll = model.pinNotifyAll as? NSNumber ?? notifyAll
        replyInfo = model.replyInfo?.toClass ?? replyInfo
        forwardInfo = model.forwardInfo?.toClass ?? forwardInfo
        replyToMessageId = model.replyInfo?.repliedToMessageId?.nsValue
        callHistory = model.callHistory?.toClass ?? callHistory

        if let participant = model.participant, let threadId = threadId, let context = managedObjectContext?.sendable {
            setParticipant(participant, threadId.intValue, context)
        }
    }

    func setParticipant(_ participant: Participant, _ threadId: Int, _ context: CacheManagedContext) {
        if let participantId = participant.id {
            self.participant = CDParticipant.findOrCreate(threadId: threadId, participantId: participantId, context: context)
            self.participant?.conversation = CDConversation.findOrCreate(threadId: threadId, context: context)
            self.participant?.update(participant)
        }
    }

    func codable(fillConversation: Bool = true, fillParticipant: Bool = true) -> Model {
       return Message(threadId: threadId?.intValue,
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
                forwardInfo: forwardInfo?.toStruct,
                participant: fillParticipant ? participant?.codable : nil,
                replyInfo: replyInfo?.toStruct,
                pinTime: pinTime?.uintValue,
                notifyAll: notifyAll?.boolValue,
                callHistoryVO: callHistory?.toStruct
       )
    }
}
