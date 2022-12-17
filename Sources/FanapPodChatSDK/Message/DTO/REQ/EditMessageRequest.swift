//
// EditMessageRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
public class EditMessageRequest: UniqueIdManagerRequest, Queueable, PlainTextSendable, ReplyProtocol, MetadataProtocol, SubjectProtocol, MessageTypeProtocol {
    public var queueTime: Date = .init()
    public var messageType: MessageType
    public let repliedTo: Int?
    public let messageId: Int
    public let textMessage: String
    public let metadata: String?
    public let threadId: Int
    var content: String? { textMessage }
    var subjectId: Int { messageId }
    var chatMessageType: ChatMessageVOTypes = .editMessage
    internal var typeCode: String?

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
