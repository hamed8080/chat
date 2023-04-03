//
// ReplyMessageRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Foundation
public final class ReplyMessageRequest: SendTextMessageRequest {
    public init(threadId: Int,
                repliedTo: Int,
                textMessage: String,
                messageType: MessageType,
                metadata: String? = nil,
                systemMetadata: String? = nil,
                uniqueId: String? = nil)
    {
        super.init(threadId: threadId,
                   textMessage: textMessage,
                   messageType: messageType,
                   metadata: metadata,
                   repliedTo: repliedTo,
                   systemMetadata: systemMetadata,
                   uniqueId: uniqueId)
    }
}
