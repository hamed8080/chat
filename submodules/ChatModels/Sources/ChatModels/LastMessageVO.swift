//
// LastMessageVO.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct LastMessageVO: Codable, Identifiable, Hashable, Sendable {
    public var deletable: Bool?
    public var delivered: Bool?
    public var editable: Bool?
    public var edited: Bool?
    /// Messages with the same ID cannot exist in two different threads since they are unique to the server.
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
    public var forwardInfo: ForwardInfo?
    public var participant: Participant?
    public var replyInfo: ReplyInfo?
    public var pinTime: UInt?
    public var pinNotifyAll: Bool?
    public var callHistory: CallHistory?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        deletable = try container.decodeIfPresent(Bool.self, forKey: .deletable)
        delivered = try container.decodeIfPresent(Bool.self, forKey: .delivered)
        editable = try container.decodeIfPresent(Bool.self, forKey: .editable)
        edited = try container.decodeIfPresent(Bool.self, forKey: .edited)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        if let messageId = try container.decodeIfPresent(Int.self, forKey: .messageId) {
            id = messageId
        }
        mentioned = try container.decodeIfPresent(Bool.self, forKey: .mentioned)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        if let text = try container.decodeIfPresent(String.self, forKey: .text) {
            message = text
        }
        messageType = try container.decodeIfPresent(MessageType.self, forKey: .messageType)
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        pinned = try container.decodeIfPresent(Bool.self, forKey: .pinned)
        previousId = try container.decodeIfPresent(Int.self, forKey: .previousId)
        seen = try container.decodeIfPresent(Bool.self, forKey: .seen)
        systemMetadata = try container.decodeIfPresent(String.self, forKey: .systemMetadata)
        time = try container.decodeIfPresent(UInt.self, forKey: .time)
        timeNanos = try container.decodeIfPresent(UInt.self, forKey: .timeNanos)
        uniqueId = try container.decodeIfPresent(String.self, forKey: .uniqueId)
        forwardInfo = try container.decodeIfPresent(ForwardInfo.self, forKey: .forwardInfo)
        participant = try container.decodeIfPresent(Participant.self, forKey: .participant)
        if let pinSender = try container.decodeIfPresent(Participant.self, forKey: .sender) {
            participant = pinSender
        }
        ownerId = participant?.id
        replyInfo = try container.decodeIfPresent(ReplyInfo.self, forKey: .replyInfoVO)
        pinTime = time
        pinNotifyAll = try container.decodeIfPresent(Bool.self, forKey: .notifyAll)
        callHistory = try container.decodeIfPresent(CallHistory.self, forKey: .callHistoryVO)
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
                notifyAll: Bool? = nil,
                callHistoryVO: CallHistory? = nil)
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
        self.forwardInfo = forwardInfo
        self.participant = participant
        self.replyInfo = replyInfo
        pinNotifyAll = notifyAll
        self.pinTime = pinTime
        self.callHistory = callHistoryVO
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
        case callHistoryVO
        case ownerId // only in Encode
        case replyInfo // only in Encode
        case threadId // only in Encode
        case sender // Only for decoding in OnPin/Onunpin message responses
        case messageId // Only for decoding in OnPin/Onunpin message responses
        case text // Only for decoding in OnPin/Onunpin message responses
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
        try container.encodeIfPresent(forwardInfo, forKey: .forwardInfo)
        try container.encodeIfPresent(participant, forKey: .participant)
        try container.encodeIfPresent(replyInfo, forKey: .replyInfo)
        try container.encodeIfPresent(callHistory, forKey: .callHistoryVO)
    }
}

public extension LastMessageVO {
    var toMessage: Message {
        let messageVO = Message(threadId: threadId,
                                deletable: deletable,
                                delivered: delivered,
                                editable: editable,
                                edited: edited,
                                id: id,
                                mentioned: mentioned,
                                message: message,
                                messageType: messageType,
                                metadata: metadata,
                                ownerId: ownerId,
                                pinned: pinned,
                                previousId: previousId,
                                seen: seen,
                                systemMetadata: systemMetadata,
                                time: time,
                                timeNanos: timeNanos,
                                uniqueId: uniqueId,
                                conversation: nil,
                                forwardInfo: forwardInfo,
                                participant: participant,
                                replyInfo: replyInfo,
                                pinTime: pinTime,
                                notifyAll: pinNotifyAll,
                                callHistoryVO: callHistory)
        return messageVO
    }
}
