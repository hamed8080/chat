//
// LastActionInConversation.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct LastActionInConversation: Decodable, Sendable {
    public let conversationId: Int?
    public let lastMessage: Message?
    public let lastReaction: Reaction?

    public init(
        conversationId: Int?  = nil,
        lastMessage: Message? = nil,
        lastReaction: Reaction? = nil) {
        self.conversationId = conversationId
        self.lastMessage = lastMessage
        self.lastReaction = lastReaction
    }

    private enum CodingKeys: String, CodingKey {
        case conversationId = "threadId"
        case lastMessage = "lastMessageVO"
        case lastReaction = "lastReactionVO"
    }

    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        conversationId = try container?.decodeIfPresent(Int.self, forKey: .conversationId)
        lastMessage = try container?.decodeIfPresent(Message.self, forKey: .lastMessage)
        lastReaction = try container?.decodeIfPresent(Reaction.self, forKey: .lastReaction)
    }
}
