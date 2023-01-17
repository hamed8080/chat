//
//  Message.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

open class Message: Codable, Identifiable, Hashable {
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id && lhs.uniqueId == rhs.uniqueId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(uniqueId)
    }

    public var deletable: Bool?
    public var delivered: Bool?
    public var editable: Bool?
    public var edited: Bool?
    public var id: Int?
    public var mentioned: Bool?
    public var message: String?
    public var messageType: MessageType?
    public var metadata: String?
    public var ownerId: Int?
    public var pinned: Bool?
    public var previousId: Int?
    public var seen: Bool?
    public var systemMetadata: String?
    public var threadId: Int?
    public var time: UInt?
    public var timeNanos: UInt?
    public var uniqueId: String?
    public var conversation: Conversation?
    public var forwardInfo: ForwardInfo?
    public var participant: Participant?
    public var replyInfo: ReplyInfo?
    public var pinTime: UInt?
    public var pinNotifyAll: Bool?

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        deletable = try container.decodeIfPresent(Bool.self, forKey: .deletable)
        delivered = try container.decodeIfPresent(Bool.self, forKey: .delivered)
        editable = try container.decodeIfPresent(Bool.self, forKey: .editable)
        edited = try container.decodeIfPresent(Bool.self, forKey: .edited)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        mentioned = try container.decodeIfPresent(Bool.self, forKey: .mentioned)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        messageType = try container.decodeIfPresent(MessageType.self, forKey: .messageType)
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        pinned = try container.decodeIfPresent(Bool.self, forKey: .pinned)
        previousId = try container.decodeIfPresent(Int.self, forKey: .previousId)
        seen = try container.decodeIfPresent(Bool.self, forKey: .seen)
        systemMetadata = try container.decodeIfPresent(String.self, forKey: .systemMetadata)
        time = try container.decodeIfPresent(UInt.self, forKey: .time)
        timeNanos = try container.decodeIfPresent(UInt.self, forKey: .timeNanos)
        uniqueId = try container.decodeIfPresent(String.self, forKey: .uniqueId)
        conversation = try container.decodeIfPresent(Conversation.self, forKey: .conversation)
        forwardInfo = try container.decodeIfPresent(ForwardInfo.self, forKey: .forwardInfo)
        participant = try container.decodeIfPresent(Participant.self, forKey: .participant)
        ownerId = participant?.id
        replyInfo = try container.decodeIfPresent(ReplyInfo.self, forKey: .replyInfoVO)
        pinTime = time
        pinNotifyAll = try container.decodeIfPresent(Bool.self, forKey: .notifyAll)
    }

    public init(threadId: Int? = nil,
                deletable: Bool? = nil,
                delivered: Bool? = nil,
                editable: Bool? = nil,
                edited: Bool? = nil,
                id: Int? = nil,
                mentioned: Bool? = nil,
                message: String? = nil,
                messageType: MessageType? = nil,
                metadata: String? = nil,
                ownerId: Int? = nil,
                pinned: Bool? = nil,
                previousId: Int? = nil,
                seen: Bool? = nil,
                systemMetadata: String? = nil,
                time: UInt? = nil,
                timeNanos: UInt? = nil,
                uniqueId: String? = nil,
                conversation: Conversation? = nil,
                forwardInfo: ForwardInfo? = nil,
                participant: Participant? = nil,
                replyInfo: ReplyInfo? = nil,
                pinTime: UInt? = nil,
                notifyAll: Bool? = nil)
    {
        self.threadId = threadId
        self.deletable = deletable
        self.delivered = delivered
        self.editable = editable
        self.edited = edited
        self.id = id
        self.mentioned = mentioned
        self.message = message
        self.messageType = messageType
        self.metadata = metadata
        self.ownerId = ownerId ?? participant?.id
        self.pinned = pinned
        self.previousId = previousId
        self.seen = seen
        self.systemMetadata = systemMetadata
        self.time = time
        self.timeNanos = timeNanos
        self.uniqueId = uniqueId
        self.conversation = conversation
        self.forwardInfo = forwardInfo
        self.participant = participant
        self.replyInfo = replyInfo
        pinNotifyAll = notifyAll
        self.pinTime = pinTime
    }

    private enum CodingKeys: String, CodingKey {
        case deletable
        case delivered
        case editable
        case edited
        case id
        case mentioned
        case message
        case messageType
        case metadata
        case pinned
        case previousId
        case seen
        case systemMetadata
        case time
        case timeNanos
        case notifyAll
        case uniqueId
        case conversation
        case forwardInfo
        case participant
        case replyInfoVO
        case ownerId // only in Encode
        case replyInfo // only in Encode
        case threadId // only in Encode
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(deletable, forKey: .deletable)
        try container.encodeIfPresent(delivered, forKey: .delivered)
        try container.encodeIfPresent(editable, forKey: .editable)
        try container.encodeIfPresent(edited, forKey: .edited)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(mentioned, forKey: .mentioned)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encodeIfPresent(messageType, forKey: .messageType)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(ownerId, forKey: .ownerId)
        try container.encodeIfPresent(previousId, forKey: .previousId)
        try container.encodeIfPresent(seen, forKey: .seen)
        try container.encodeIfPresent(systemMetadata, forKey: .systemMetadata)
        try container.encodeIfPresent(threadId, forKey: .threadId)
        try container.encodeIfPresent(time, forKey: .time)
        try container.encodeIfPresent(timeNanos, forKey: .timeNanos)
        try container.encodeIfPresent(uniqueId, forKey: .uniqueId)
        try container.encodeIfPresent(conversation, forKey: .conversation)
        try container.encodeIfPresent(forwardInfo, forKey: .forwardInfo)
        try container.encodeIfPresent(participant, forKey: .participant)
        try container.encodeIfPresent(replyInfo, forKey: .replyInfo)
    }

    // FIXME: need fix with object decoding in this calss with FileMetaData for proerty metadata
    public var metaData: FileMetaData? {
        guard let metadata = metadata?.data(using: .utf8),
              let metaData = try? JSONDecoder().decode(FileMetaData.self, from: metadata) else { return nil }
        return metaData
    }
}
