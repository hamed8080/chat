//
// UnreadMessageCountRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
public final class UnreadMessageCountRequest: UniqueIdManagerRequest, ChatSendable {
    let countMutedThreads: Bool
    var chatMessageType: ChatMessageVOTypes = .allUnreadMessageCount
    var content: String? { convertCodableToString() }

    public init(countMutedThreads: Bool = false, uniqueId: String? = nil) {
        self.countMutedThreads = countMutedThreads
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case mute
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(countMutedThreads, forKey: .mute)
    }
}
