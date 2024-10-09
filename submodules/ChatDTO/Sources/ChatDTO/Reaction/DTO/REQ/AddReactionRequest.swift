//
// AddReactionRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct AddReactionRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let messageId: Int
    public let conversationId: Int
    public let reaction: Sticker
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(messageId: Int, conversationId: Int, reaction: Sticker, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.messageId = messageId
        self.reaction = reaction
        self.conversationId = conversationId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
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
