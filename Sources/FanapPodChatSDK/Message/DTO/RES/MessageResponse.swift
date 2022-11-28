//
// MessageResponse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class MessageResponse: Decodable {
    public var threadId: Int?
    public var participantId: Int?
    public var messageId: Int?
    public var messageTime: UInt?

    public init(threadId: Int? = nil, participantId: Int? = nil, messageId: Int? = nil, messageTime: UInt? = nil) {
        self.threadId = threadId
        self.participantId = participantId
        self.messageId = messageId
        self.messageTime = messageTime
    }

    enum CodingKeys: String, CodingKey {
        case threadId = "conversationId"
        case participantId
        case messageId
        case messageTime
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.threadId = try container.decodeIfPresent(Int.self, forKey: .threadId)
        self.participantId = try container.decodeIfPresent(Int.self, forKey: .participantId)
        self.messageId = try container.decodeIfPresent(Int.self, forKey: .messageId)
        self.messageTime = try container.decodeIfPresent(UInt.self, forKey: .messageTime)
    }
}

public class SentMessageResponse: MessageResponse {
    public var isSent: Bool

    public init(isSent: Bool, threadId: Int? = nil, messageId: Int? = nil, messageTime: UInt? = nil) {
        self.isSent = isSent
        super.init(threadId: threadId, participantId: nil, messageId: messageId, messageTime: messageTime)
    }

    required public init(from decoder: Decoder) throws {
        isSent = true
        try super.init(from: decoder)
    }
}

public class DeliverMessageResponse: MessageResponse {
    public var isDeliver: Bool


    public init(isDeliver: Bool, threadId: Int? = nil, messageId: Int? = nil, messageTime: UInt? = nil) {
        self.isDeliver = isDeliver
        super.init(threadId: threadId, messageId: messageId, messageTime: messageTime)
    }

    required public init(from decoder: Decoder) throws {
        isDeliver = true
        try super.init(from: decoder)
    }
}

public class SeenMessageResponse: MessageResponse {
    public var isSeen: Bool


    public init(isSeen: Bool, threadId: Int? = nil, messageId: Int? = nil, messageTime: UInt? = nil) {
        self.isSeen = isSeen
        super.init(threadId: threadId, messageId: messageId, messageTime: messageTime)
    }

    required public init(from decoder: Decoder) throws {
        isSeen = true
        try super.init(from: decoder)
    }
}
