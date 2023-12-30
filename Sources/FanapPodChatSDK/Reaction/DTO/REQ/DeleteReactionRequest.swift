//
// DeleteReactionRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public class DeleteReactionRequest: UniqueIdManagerRequest, Encodable, ChatSendable, SubjectProtocol {
    var chatMessageType: ChatMessageVOTypes = .removeReaction
    var content: String? { convertCodableToString() }
    public let reactionId: Int
    public let conversationId: Int
    var subjectId: Int { conversationId }

    public init(reactionId: Int, conversationId: Int, uniqueId: String? = nil, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.reactionId = reactionId
        self.conversationId = conversationId
        super.init(uniqueId: uniqueId, typeCodeIndex: typeCodeIndex)
    }

    private enum CodingKeys: CodingKey {
        case reactionId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.reactionId, forKey: .reactionId)
    }
}
