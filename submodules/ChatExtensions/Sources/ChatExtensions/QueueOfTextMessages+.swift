//
// QueueOfTextMessages+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatDTO
import ChatModels

public extension QueueOfTextMessages {
    init(textRequest: SendTextMessageRequest) {
       self.init(messageType: textRequest.messageType,
                 metadata: textRequest.metadata,
                 repliedTo: textRequest.repliedTo,
                 systemMetadata: textRequest.systemMetadata,
                 textMessage: textRequest.textMessage,
                 threadId: textRequest.threadId,
                 uniqueId: textRequest.uniqueId)
    }
}
