//
// MessageSeenRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/28/22

import Foundation
import ChatCore

public final class MessageSeenRequest: UniqueIdManagerRequest, PlainTextSendable {
    public let messageId: Int
    public let threadId: Int
    public var content: String? { "\(messageId)" }
    public var chatMessageType: ChatMessageVOTypes = .seen

    public init(threadId: Int, messageId: Int, uniqueId: String? = nil) {
        self.messageId = messageId
        self.threadId = threadId
        super.init(uniqueId: uniqueId)
    }
}
