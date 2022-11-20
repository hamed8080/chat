//
// MentionRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public class ThreadsMentionRequest: UniqueIdManagerRequest, ChatSendable {
    public let threadIds: [Int]
    var content: String? { threadIds.convertCodableToString() }
    var chatMessageType: ChatMessageVOTypes = .mentionInUnreadMessage

    public init(threadIds: [Int], uniqueId: String? = nil) {
        self.threadIds = threadIds
        super.init(uniqueId: uniqueId)
    }
}
