//
// MessageSeenRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class MessageSeenRequest: UniqueIdManagerRequest, PlainTextSendable {
    let messageId: Int
    let threadId: Int
    var content: String? { "\(messageId)" }
    var chatMessageType: ChatMessageVOTypes = .seen

    public init(threadId: Int, messageId: Int, uniqueId: String? = nil) {
        self.messageId = messageId
        self.threadId = threadId
        super.init(uniqueId: uniqueId)
    }
}
