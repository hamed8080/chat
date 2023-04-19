//
// ThreadsRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Async
import Foundation
import ChatCore

public final class ThreadsUnreadCountRequest: UniqueIdManagerRequest, ChatSendable {
    public let threadIds: [Int]
    public var chatMessageType: ChatMessageVOTypes = .threadsUnreadCount
    public var content: String? { threadIds.jsonString }

    public init(threadIds: [Int], uniqueId: String? = nil) {
        self.threadIds = threadIds
        super.init(uniqueId: uniqueId)
    }

    public func encode(to _: Encoder) throws {}
}
