//
// ThreadsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import FanapPodAsyncSDK
import Foundation

public class ThreadsUnreadCountRequest: UniqueIdManagerRequest, ChatSendable {
    public let threadIds: [Int]
    var chatMessageType: ChatMessageVOTypes = .threadsUnreadCount
    var content: String? { threadIds.convertCodableToString() }

    public init(threadIds: [Int], uniqueId: String? = nil) {
        self.threadIds = threadIds
        super.init(uniqueId: uniqueId)
    }

    public func encode(to _: Encoder) throws {}
}
