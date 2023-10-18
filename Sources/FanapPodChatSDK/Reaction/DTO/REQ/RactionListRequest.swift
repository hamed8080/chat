//
// RactionListRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public class RactionListRequest: UniqueIdManagerRequest, Encodable, ChatSendable, SubjectProtocol {
    public let messageId: Int
    public var offset: Int
    public let count: Int
    public let conversationId: Int
    /// To filter reactions based on a specific sticker.
    public let sticker: Sticker?
    var chatMessageType: ChatMessageVOTypes = .reactionList
    var content: String? { convertCodableToString() }
    var subjectId: Int { conversationId }

    public init(messageId: Int, offset: Int = 0, count: Int = 25, conversationId: Int, sticker: Sticker? = nil, uniqueId: String? = nil) {
        self.messageId = messageId
        self.count = count
        self.offset = offset
        self.conversationId = conversationId
        self.sticker = sticker
        super.init(uniqueId: uniqueId)
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
