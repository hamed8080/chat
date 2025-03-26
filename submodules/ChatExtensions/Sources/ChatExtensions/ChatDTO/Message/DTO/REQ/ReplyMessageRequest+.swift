//
// ReplyMessageRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation
import ChatModels

extension ReplyMessageRequest: @retroactive Queueable, @retroactive PlainTextSendable, @retroactive ReplyProtocol, @retroactive MessageTypeProtocol, @retroactive MetadataProtocol, @retroactive SystemtMetadataProtocol, @retroactive SubjectProtocol {
}

public extension ReplyMessageRequest {
    var content: String? { textMessage }
    var subjectId: Int { threadId }
    var _messageType: ChatCore.MessageType? { ChatCore.MessageType(rawValue: self.messageType.rawValue) }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
