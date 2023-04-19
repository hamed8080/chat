//
// BlockedAssistantsRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public final class BlockedAssistantsRequest: UniqueIdManagerRequest, ChatSendable {
    public let count: Int
    public let offset: Int
    public var chatMessageType: ChatMessageVOTypes = .blockedAssistnts
    public var content: String? { jsonString }

    public init(count: Int = 25, offset: Int = 0, uniqueId: String? = nil) {
        self.count = count
        self.offset = offset
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case count
        case offset
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(count, forKey: .count)
        try? container.encodeIfPresent(offset, forKey: .offset)
    }
}
