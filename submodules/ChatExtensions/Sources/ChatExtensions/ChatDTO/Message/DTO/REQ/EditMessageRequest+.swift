//
// EditMessageRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatCore
import ChatDTO
import ChatModels

extension EditMessageRequest: Queueable, PlainTextSendable, ReplyProtocol, MetadataProtocol, SubjectProtocol, MessageTypeProtocol {
}

public extension EditMessageRequest {
    var content: String? { textMessage }
    var subjectId: Int { messageId }
    var _messageType: ChatCore.MessageType? { ChatCore.MessageType(rawValue: messageType.rawValue) }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}

public extension EditMessageRequest {
    var queueOfTextMessages: QueueOfEditMessages {
        .init(messageType: messageType,
              metadata: metadata,
              repliedTo: repliedTo,
              textMessage: textMessage,
              threadId: threadId,
              uniqueId: uniqueId)
    }
}

