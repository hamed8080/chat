//
// MessageDeliveredUsersRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class MessageDeliveredUsersRequest: BaseRequest {
    let messageId: Int
    let offset: Int
    let count: Int

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

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(messageId, forKey: .messageId)
        try? container.encode(offset, forKey: .offset)
        try? container.encode(count, forKey: .count)
    }
}
