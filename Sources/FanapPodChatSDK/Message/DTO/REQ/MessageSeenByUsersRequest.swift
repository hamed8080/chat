//
// MessageSeenByUsersRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
public class MessageSeenByUsersRequest: UniqueIdManagerRequest, ChatSendable {
    let messageId: Int
    let offset: Int
    let count: Int
    var chatMessageType: ChatMessageVOTypes = .getMessageSeenParticipants
    var content: String? { convertCodableToString() }

    public init(messageId: Int, count: Int = 50, offset: Int = 0, uniqueId: String? = nil, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.messageId = messageId
        self.offset = offset
        self.count = count
        super.init(uniqueId: uniqueId, typeCodeIndex: typeCodeIndex)
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
