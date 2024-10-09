//
// QueueOfEditMessages+.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

extension QueueOfEditMessages {
    public var request: EditMessageRequest {
        EditMessageRequest(threadId: threadId ?? -1,
                           messageType: messageType ?? .unknown,
                           messageId: messageId ?? -1,
                           textMessage: textMessage ?? "",
                           repliedTo: repliedTo,
                           metadata: metadata,
                           uniqueId: uniqueId ?? "")
    }
}
