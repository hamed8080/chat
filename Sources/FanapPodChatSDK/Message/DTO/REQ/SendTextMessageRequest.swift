//
// SendTextMessageRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class SendTextMessageRequest: BaseRequest {
    public let messageType: MessageType
    public var metadata: String?
    public let repliedTo: Int?
    public let systemMetadata: String?
    public let textMessage: String
    public var threadId: Int

    public init(threadId: Int? = nil,
                textMessage: String,
                messageType: MessageType,
                metadata: String? = nil,
                repliedTo: Int? = nil,
                systemMetadata: String? = nil,
                uniqueId: String? = nil)
    {
        self.messageType = messageType
        self.metadata = metadata
        self.repliedTo = repliedTo
        self.systemMetadata = systemMetadata
        self.textMessage = textMessage
        self.threadId = threadId ?? -1
        super.init(uniqueId: uniqueId)
    }
}
