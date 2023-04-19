//
// GetHistoryRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class GetHistoryRequest: UniqueIdManagerRequest, ChatSendable, SubjectProtocol {
    public let threadId: Int
    public var offset: Int
    public var count: Int
    public let fromTime: UInt?
    public let fromTimeNanos: UInt?
    public let messageId: Int?
    public let messageType: Int?
    public let metadataCriteria: SearchMetadataCriteria?
    public let order: String?
    public let query: String?
    public let toTime: UInt?
    public let hashtag: String?
    public let toTimeNanos: UInt?
    public let uniqueIds: [String]?
    public let userId: Int?
    public var messageThreadId: Int?
    public var firstMessageId: Int?
    public var lastMessageId: Int?
    public var senderId: Int?
    public var historyTime: UInt?
    public var allMentioned: Bool?
    public var unreadMentioned: Bool?
    public var lastMessageTime: UInt?
    public var historyEndTime: UInt?
    public var readOnly: Bool = false
    public var newMessages: Bool?

    public var chatMessageType: ChatMessageVOTypes = .getHistory
    public var subjectId: Int { threadId }
    public var content: String? { jsonString }

    /// - Parameters:
    ///   - readOnly: This property prevent to write to cache when you only need to view messages of a thread pass true if you need to only view messages.
    public init(threadId: Int,
                count: Int? = nil,
                fromTime: UInt? = nil,
                fromTimeNanos: UInt? = nil,
                messageId: Int? = nil,
                messageType: Int? = nil,
                metadataCriteria: SearchMetadataCriteria? = nil,
                offset: Int? = nil,
                order: String? = nil,
                query: String? = nil,
                toTime: UInt? = nil,
                toTimeNanos: UInt? = nil,
                uniqueIds: [String]? = nil,
                userId: Int? = nil,
                hashtag: String? = nil,
                messageThreadId: Int? = nil,
                firstMessageId: Int? = nil,
                lastMessageId: Int? = nil,
                senderId: Int? = nil,
                historyTime: UInt? = nil,
                allMentioned: Bool? = nil,
                unreadMentioned: Bool? = nil,
                lastMessageTime: UInt? = nil,
                historyEndTime: UInt? = nil,
                readOnly: Bool = false,
                newMessages: Bool? = nil,
                uniqueId: String? = nil)
    {
        self.threadId = threadId
        self.count = count ?? 25
        self.offset = offset ?? 0
        self.fromTime = fromTime
        self.fromTimeNanos = fromTimeNanos
        self.messageId = messageId
        self.messageType = messageType
        self.metadataCriteria = metadataCriteria
        self.order = order
        self.query = query
        self.toTime = toTime
        self.hashtag = hashtag
        self.toTimeNanos = toTimeNanos
        self.uniqueIds = uniqueIds
        self.userId = userId
        self.messageThreadId = messageThreadId
        self.firstMessageId = firstMessageId
        self.lastMessageId = lastMessageId
        self.senderId = senderId
        self.historyTime = historyTime
        self.allMentioned = allMentioned
        self.unreadMentioned = unreadMentioned
        self.lastMessageTime = lastMessageTime
        self.historyEndTime = historyEndTime
        self.readOnly = readOnly
        self.newMessages = newMessages
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case count
        case offset
        case fromTime
        case fromTimeNanos
        case messageId = "id"
        case messageType
        case metadataCriteria
        case order
        case query
        case toTime
        case hashtag
        case toTimeNanos
        case uniqueIds
        case userId
        case messageThreadId
        case firstMessageId
        case lastMessageId
        case senderId
        case historyTime
        case allMentioned
        case unreadMentioned
        case lastMessageTime
        case historyEndTime
        case newMessages
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(count, forKey: .count)
        try container.encode(offset, forKey: .offset)
        try container.encodeIfPresent(fromTime, forKey: .fromTime)
        try container.encodeIfPresent(fromTimeNanos, forKey: .fromTimeNanos)
        try container.encodeIfPresent(toTime, forKey: .toTime)
        try container.encodeIfPresent(toTimeNanos, forKey: .toTimeNanos)
        try container.encodeIfPresent(order, forKey: .order)
        try container.encodeIfPresent(query, forKey: .query)
        try container.encodeIfPresent(messageId, forKey: .messageId)
        try container.encodeIfPresent(metadataCriteria, forKey: .metadataCriteria)
        try container.encodeIfPresent(uniqueIds, forKey: .uniqueIds)
        try container.encodeIfPresent(messageType, forKey: .messageType)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encodeIfPresent(hashtag, forKey: .hashtag)
        try container.encodeIfPresent(messageThreadId, forKey: .messageThreadId)
        try container.encodeIfPresent(firstMessageId, forKey: .firstMessageId)
        try container.encodeIfPresent(lastMessageId, forKey: .lastMessageId)
        try container.encodeIfPresent(senderId, forKey: .senderId)
        try container.encodeIfPresent(historyTime, forKey: .historyTime)
        try container.encodeIfPresent(allMentioned, forKey: .allMentioned)
        try container.encodeIfPresent(unreadMentioned, forKey: .unreadMentioned)
        try container.encodeIfPresent(lastMessageTime, forKey: .lastMessageTime)
        try container.encodeIfPresent(historyEndTime, forKey: .historyEndTime)
        try container.encodeIfPresent(newMessages, forKey: .newMessages)
    }
}
