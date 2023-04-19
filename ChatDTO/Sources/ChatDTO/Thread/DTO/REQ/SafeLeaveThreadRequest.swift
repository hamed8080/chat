//
// SafeLeaveThreadRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Foundation
public final class SafeLeaveThreadRequest: LeaveThreadRequest {
    public let participantId: Int

    public init(threadId: Int, participantId: Int, clearHistory: Bool? = false, uniqueId: String? = nil) {
        self.participantId = participantId
        super.init(threadId: threadId, clearHistory: clearHistory, uniqueId: uniqueId)
    }
}
