//
// ReactionListRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct ReactionListRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let messageId: Int
    public var offset: Int
    public let count: Int
    public let conversationId: Int
    public let uniqueId: String
    /// To filter reactions based on a specific sticker.
    public let sticker: Sticker?
    public var typeCodeIndex: Index

    public init(messageId: Int, offset: Int = 0, count: Int = 25, conversationId: Int, sticker: Sticker? = nil, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.messageId = messageId
        self.count = count
        self.offset = offset
        self.conversationId = conversationId
        self.sticker = sticker
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    enum CodingKeys: CodingKey {
        case messageId
        case offset
        case count
        case sticker
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.messageId, forKey: .messageId)
        try container.encode(self.offset, forKey: .offset)
        try container.encode(self.count, forKey: .count)
        try container.encodeIfPresent(self.sticker, forKey: .sticker)
    }
}
