//
// MessageResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public enum MessageResponseState {
    case sent
    case delivered
    case seen
}

public struct MessageResponse: Decodable {
    public var threadId: Int?
    public var participantId: Int?
    public var messageId: Int?
    public var messageTime: UInt?
    public var messageState: MessageResponseState?

    public init(messageState: MessageResponseState, threadId: Int? = nil, participantId: Int? = nil, messageId: Int? = nil, messageTime: UInt? = nil) {
        self.messageState = messageState
        self.threadId = threadId
        self.participantId = participantId
        self.messageId = messageId
        self.messageTime = messageTime
    }

    private enum CodingKeys: String, CodingKey {
        case threadId = "conversationId"
        case participantId
        case messageId
        case messageTime
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        threadId = try container.decodeIfPresent(Int.self, forKey: .threadId)
        participantId = try container.decodeIfPresent(Int.self, forKey: .participantId)
        messageId = try container.decodeIfPresent(Int.self, forKey: .messageId)
        messageTime = try container.decodeIfPresent(UInt.self, forKey: .messageTime)
    }
}
