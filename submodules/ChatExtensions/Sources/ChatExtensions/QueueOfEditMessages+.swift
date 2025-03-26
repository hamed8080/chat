//
// QueueOfEditMessages+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatModels
import ChatDTO

public extension QueueOfEditMessages {
    init(edit: EditMessageRequest) {
       self.init(messageId: edit.messageId,
                 messageType: edit.messageType,
                 metadata: edit.metadata,
                 repliedTo: edit.repliedTo,
                 textMessage: edit.textMessage,
                 threadId: edit.threadId,
                 uniqueId: edit.uniqueId)
    }
}
