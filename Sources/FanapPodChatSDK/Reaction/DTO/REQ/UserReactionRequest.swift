//
// UserReactionRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public class UserReactionRequest: UniqueIdManagerRequest, Encodable, ChatSendable, SubjectProtocol {
    public let messageId: Int
    public let conversationId: Int
    var chatMessageType: ChatMessageVOTypes = .getReaction
    var content: String? { convertCodableToString() }
    var subjectId: Int { conversationId }

    public init(messageId: Int, conversationId: Int, uniqueId: String? = nil) {
        self.messageId = messageId
        self.conversationId = conversationId
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case messageId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageId, forKey: .messageId)
    }
}
