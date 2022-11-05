//
// SafeLeaveThreadRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class SafeLeaveThreadRequest: LeaveThreadRequest {
    public let participantId: Int

    public init(threadId: Int, participantId: Int, clearHistory: Bool? = false, uniqueId: String? = nil) {
        self.participantId = participantId
        super.init(threadId: threadId, clearHistory: clearHistory, uniqueId: uniqueId)
    }
}
