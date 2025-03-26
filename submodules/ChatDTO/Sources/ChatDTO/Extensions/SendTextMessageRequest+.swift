//
// SendTextMessageRequest+.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

extension SendTextMessageRequest {
    internal init(request: SendTextMessageRequest, uniqueId: String) {
        self = .init(threadId: request.threadId,
                     textMessage: request.textMessage,
                     messageType: request.messageType,
                     metadata: request.metadata,
                     repliedTo: request.repliedTo,
                     systemMetadata: request.systemMetadata,
                     uniqueId: uniqueId)
    }
}
