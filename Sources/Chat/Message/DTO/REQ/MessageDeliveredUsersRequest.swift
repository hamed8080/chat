//
// MessageDeliveredUsersRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
public final class MessageDeliveredUsersRequest: UniqueIdManagerRequest, ChatSendable {
    let messageId: Int
    let offset: Int
    let count: Int
    var content: String? { jsonString }
    var chatMessageType: ChatMessageVOTypes = .messageDeliveredToParticipants

    public init(messageId: Int, count: Int = 50, offset: Int = 0, uniqueId: String? = nil) {
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
