//
// SafeLeaveThreadRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/2/22

import Foundation
public class SafeLeaveThreadRequest: LeaveThreadRequest {
    public let participantId: Int

    public init(threadId: Int, participantId: Int, clearHistory: Bool? = false, uniqueId: String? = nil, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.participantId = participantId
        super.init(threadId: threadId, clearHistory: clearHistory, uniqueId: uniqueId, typeCodeIndex: typeCodeIndex)
    }
}
