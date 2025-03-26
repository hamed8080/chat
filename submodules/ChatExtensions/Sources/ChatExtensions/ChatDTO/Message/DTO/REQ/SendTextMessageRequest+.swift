//
// SendTextMessageRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatCore
import Foundation
import ChatModels

extension SendTextMessageRequest: @retroactive Queueable, @retroactive PlainTextSendable, @retroactive ReplyProtocol, @retroactive MessageTypeProtocol, @retroactive MetadataProtocol, @retroactive SystemtMetadataProtocol, @retroactive SubjectProtocol {}

public extension SendTextMessageRequest {
    var content: String? { textMessage }
    var subjectId: Int { threadId }
    var _messageType: ChatCore.MessageType? { ChatCore.MessageType(rawValue: self.messageType.rawValue) }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}

public extension SendTextMessageRequest {
    var queueOfTextMessages: QueueOfTextMessages {
        .init(messageType: messageType,
              metadata: metadata,
              repliedTo: repliedTo,
              systemMetadata: systemMetadata,
              textMessage: textMessage,
              threadId: threadId,
              uniqueId: uniqueId)
    }

    func queueOfFileMessages(_ request: UploadFileRequest) -> QueueOfFileMessages {
        .init(req: self, uploadFile: request)
    }

    func queueOfFileMessages(_ request: UploadImageRequest) -> QueueOfFileMessages {
        .init(req: self, imageRequest: request)
    }
}

