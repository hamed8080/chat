//
// MessageDeliverRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class MessageDeliverRequest: BaseRequest, PlainTextSendable {
    let messageId: String
    var content: String? { messageId }
    var chatMessageType: ChatMessageVOTypes = .delivery

    public init(messageId: Int, uniqueId: String? = nil) {
        self.messageId = "\(messageId)"
        super.init(uniqueId: uniqueId)
    }
}
