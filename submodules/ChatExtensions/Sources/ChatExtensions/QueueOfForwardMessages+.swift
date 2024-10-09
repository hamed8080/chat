//
// QueueOfForwardMessages+.swift
// Copyright (c) 2022 ChatExtensions
//
// Created by Hamed Hosseini on 12/14/22

import ChatModels
import ChatDTO

public extension QueueOfForwardMessages {
    init(forward: ForwardMessageRequest) {
        self.init(fromThreadId: forward.fromThreadId,
                  messageIds: forward.messageIds,
                  threadId: forward.threadId,
                  uniqueIds: forward.uniqueIds)
    }
}
