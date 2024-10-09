//
// ReplyPrivatelyRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation
import ChatModels

extension ReplyPrivatelyRequest: Queueable, PlainTextSendable, ReplyProtocol, MessageTypeProtocol, MetadataProtocol, SystemtMetadataProtocol, SubjectProtocol {
}

public extension ReplyPrivatelyRequest {
    var content: String? { replyContent.jsonString }
    var subjectId: Int { replyContent.fromConversationId }
    var _messageType: ChatCore.MessageType? { ChatCore.MessageType(rawValue: self.messageType.rawValue) ?? .unknown }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}
