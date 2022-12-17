//
// BlockedAssistantsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
public class BlockedAssistantsRequest: UniqueIdManagerRequest, ChatSendable {
    internal let count: Int
    internal let offset: Int
    var chatMessageType: ChatMessageVOTypes = .blockedAssistnts
    var content: String? { convertCodableToString() }

    public init(count: Int = 50, offset: Int = 0, uniqueId: String? = nil) {
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
