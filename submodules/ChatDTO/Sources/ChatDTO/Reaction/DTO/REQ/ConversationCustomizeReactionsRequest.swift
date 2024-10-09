//
// ConversationCustomizeReactionsRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct ConversationCustomizeReactionsRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let conversationId: Int
    public let reactionStatus: ReactionStatus
    public let allowedReactions: [Sticker]?
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(conversationId: Int, reactionStatus: ReactionStatus, allowedReactions: [Sticker]? = nil, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.reactionStatus = reactionStatus
        self.allowedReactions = allowedReactions
        self.conversationId = conversationId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }
    
    private enum CodingKeys: String, CodingKey {
        case reactionStatus
        case allowedReactions
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reactionStatus, forKey: .reactionStatus)
        try container.encodeIfPresent(allowedReactions, forKey: .allowedReactions)
    }

}
