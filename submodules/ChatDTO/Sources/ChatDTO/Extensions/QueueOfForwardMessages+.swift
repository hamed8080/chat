//
// QueueOfForwardMessages+.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

extension QueueOfForwardMessages {
    public var request: ForwardMessageRequest {
        ForwardMessageRequest(fromThreadId: fromThreadId ?? -1,
                              threadId: threadId ?? -1,
                              messageIds: messageIds ?? [],
                              uniqueIds: uniqueIds ?? [])
    }
}
