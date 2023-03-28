//
// MessageResponse.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/9/22

import Foundation

public enum MessageResposneState {
    case sent
    case delivered
    case seen
}

public final class MessageResponse: Decodable {
    public var threadId: Int?
    public var participantId: Int?
    public var messageId: Int?
    public var messageTime: UInt?
    public var messageState: MessageResposneState?

    public init(messageState: MessageResposneState, threadId: Int? = nil, participantId: Int? = nil, messageId: Int? = nil, messageTime: UInt? = nil) {
        self.messageState = messageState
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

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        threadId = try container.decodeIfPresent(Int.self, forKey: .threadId)
        participantId = try container.decodeIfPresent(Int.self, forKey: .participantId)
        messageId = try container.decodeIfPresent(Int.self, forKey: .messageId)
        messageTime = try container.decodeIfPresent(UInt.self, forKey: .messageTime)
    }
}
