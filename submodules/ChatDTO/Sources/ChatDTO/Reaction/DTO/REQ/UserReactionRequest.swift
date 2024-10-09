//
// UserReactionRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct UserReactionRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let messageId: Int
    public let conversationId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(messageId: Int, conversationId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.messageId = messageId
        self.conversationId = conversationId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case messageId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageId, forKey: .messageId)
    }
}
