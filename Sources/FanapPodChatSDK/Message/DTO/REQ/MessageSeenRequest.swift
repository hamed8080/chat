//
// MessageSeenRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class MessageSeenRequest: UniqueIdManagerRequest, PlainTextSendable {
    let messageId: String
    var content: String? { messageId }
    var chatMessageType: ChatMessageVOTypes = .seen

    public init(messageId: Int, uniqueId: String? = nil) {
        self.messageId = "\(messageId)"
        super.init(uniqueId: uniqueId)
    }
}
