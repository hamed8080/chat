//
// EditMessageRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class EditMessageRequest: BaseRequest, Queueable, PlainTextSendable, ReplyProtocol, MetadataProtocol, SubjectProtocol, MessageTypeProtocol {
    public var messageType: MessageType
    public let repliedTo: Int?
    public let messageId: Int
    public let textMessage: String
    public let metadata: String?
    public let threadId: Int
    var content: String? { textMessage }
    var subjectId: Int? { threadId }
    var chatMessageType: ChatMessageVOTypes = .editMessage

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
