//
// AddReactionRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public class AddReactionRequest: UniqueIdManagerRequest, Encodable, ChatSendable, SubjectProtocol {
    public let messageId: Int
    public let conversationId: Int
    public let reaction: Sticker
    var chatMessageType: ChatMessageVOTypes = .addReaction
    var content: String? { convertCodableToString() }
    var subjectId: Int { conversationId }

    public init(messageId: Int, conversationId: Int, reaction: Sticker, uniqueId: String? = nil) {
        self.messageId = messageId
        self.reaction = reaction
        self.conversationId = conversationId
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case messageId
        case reaction
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageId, forKey: .messageId)
        try container.encode(reaction, forKey: .reaction)
    }
}
