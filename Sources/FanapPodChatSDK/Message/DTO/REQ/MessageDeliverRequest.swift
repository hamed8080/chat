//
// MessageDeliverRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/16/22

import Foundation
public final class MessageDeliverRequest: UniqueIdManagerRequest, PlainTextSendable {
    let messageId: String
    let threadId: Int?
    var content: String? { messageId }
    var chatMessageType: ChatMessageVOTypes = .delivery

    public init(messageId: Int, threadId: Int?, uniqueId: String? = nil) {
        self.messageId = "\(messageId)"
        self.threadId = threadId
        super.init(uniqueId: uniqueId)
    }
}
