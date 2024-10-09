//
// DeleteReactionRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct DeleteReactionRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let reactionId: Int
    public let conversationId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(reactionId: Int, conversationId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.reactionId = reactionId
        self.conversationId = conversationId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case reactionId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.reactionId, forKey: .reactionId)
    }
}
