//
// MessageSeenByUsersRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class MessageSeenByUsersRequest: UniqueIdManagerRequest, ChatSendable {
    public let messageId: Int
    public let offset: Int
    public let count: Int
    public var chatMessageType: ChatMessageVOTypes = .getMessageSeenParticipants
    public var content: String? { jsonString }

    public init(messageId: Int, count: Int = 25, offset: Int = 0, uniqueId: String? = nil) {
        self.messageId = messageId
        self.offset = offset
        self.count = count
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case messageId
        case offset
        case count
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(messageId, forKey: .messageId)
        try? container.encode(offset, forKey: .offset)
        try? container.encode(count, forKey: .count)
    }
}
