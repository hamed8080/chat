//
// ForwardMessageRequest+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatCore
import ChatDTO
import ChatModels

extension ForwardMessageRequest: Queueable, PlainTextSendable, SubjectProtocol {}

public extension ForwardMessageRequest {
    var subjectId: Int { threadId }
    var content: String? { "\(messageIds)" }
    var chatTypeCodeIndex: Index { typeCodeIndex }
}

public extension ForwardMessageRequest {
    var queueOfForwardMessages: QueueOfForwardMessages {
        .init(fromThreadId: fromThreadId,
              messageIds: messageIds,
              threadId: threadId,
              uniqueIds: uniqueIds)
    }
}
