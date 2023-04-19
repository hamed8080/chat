//
// JoinPublicThreadRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/16/22

import Foundation
import ChatModels
import ChatCore

public final class JoinPublicThreadRequest: UniqueIdManagerRequest, PlainTextSendable {
    public var threadName: String
    public var chatMessageType: ChatMessageVOTypes = .joinThread
    public var content: String? { threadName }

    public init(threadName: String, uniqueId: String? = nil) {
        self.threadName = threadName
        super.init(uniqueId: uniqueId)
    }
}
