//
// QueueOfTextMessages+.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

extension QueueOfTextMessages {
    public var request: SendTextMessageRequest {
        SendTextMessageRequest(threadId: threadId ?? -1,
                               textMessage: textMessage ?? "",
                               messageType: messageType ?? .unknown,
                               metadata: metadata,
                               repliedTo: repliedTo,
                               systemMetadata: systemMetadata,
                               uniqueId: uniqueId ?? UUID().uuidString)
    }
}
