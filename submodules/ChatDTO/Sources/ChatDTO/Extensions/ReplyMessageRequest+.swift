//
// ReplyMessageRequest+.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

extension ReplyMessageRequest {
    public var textMessageRequest: SendTextMessageRequest {
        .init(threadId: threadId,
              textMessage: textMessage,
              messageType: ChatModels.MessageType(rawValue: messageType.rawValue) ?? .text,
              metadata: metadata,
              repliedTo: repliedTo,
              systemMetadata: systemMetadata,
              uniqueId: uniqueId)
    }
}
