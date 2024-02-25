//
// MessageSeenRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/28/22

import Foundation
public class MessageSeenRequest: UniqueIdManagerRequest, PlainTextSendable {
    let messageId: Int
    let threadId: Int
    var content: String? { "\(messageId)" }
    var chatMessageType: ChatMessageVOTypes = .seen

    public init(threadId: Int, messageId: Int, uniqueId: String? = nil, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.messageId = messageId
        self.threadId = threadId
        super.init(uniqueId: uniqueId, typeCodeIndex: typeCodeIndex)
    }
}
