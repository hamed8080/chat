//
// EditMessageRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class EditMessageRequest: BaseRequest {
    public let messageType: MessageType
    public let repliedTo: Int?
    public let messageId: Int
    public let textMessage: String
    public let metadata: String?
    public let threadId: Int

    public init(threadId: Int,
                messageType: MessageType,
                messageId: Int,
                textMessage: String,
                repliedTo: Int? = nil,
                metadata: String? = nil,
                uniqueId: String? = nil)
    {
        self.threadId = threadId
        self.messageType = messageType
        self.repliedTo = repliedTo
        self.messageId = messageId
        self.textMessage = textMessage
        self.metadata = metadata
        super.init(uniqueId: uniqueId)
    }
}
