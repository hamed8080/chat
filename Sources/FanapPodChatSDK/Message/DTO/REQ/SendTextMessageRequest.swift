//
// SendTextMessageRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class SendTextMessageRequest: UniqueIdManagerRequest, Queueable, PlainTextSendable, ReplyProtocol, MessageTypeProtocol, MetadataProtocol, SystemtMetadataProtocol, SubjectProtocol {
    public var queueTime: Date = Date()
    public let messageType: MessageType
    public var metadata: String?
    public let repliedTo: Int?
    public let systemMetadata: String?
    public let textMessage: String
    public var threadId: Int
    public var content: String? { textMessage }
    public var chatMessageType: ChatMessageVOTypes = .message
    public var subjectId: Int { threadId }

    public init(threadId: Int,
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
        self.threadId = threadId
        super.init(uniqueId: uniqueId)
    }
}
