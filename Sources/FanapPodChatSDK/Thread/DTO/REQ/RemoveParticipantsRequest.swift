//
// RemoveParticipantsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class RemoveParticipantsRequest: BaseRequest {
    public let participantIds: [Int]
    public let threadId: Int

    public init(participantId: Int, threadId: Int, uniqueId: String? = nil) {
        self.threadId = threadId
        participantIds = [participantId]
        super.init(uniqueId: uniqueId)
    }

    public init(participantIds: [Int], threadId: Int, uniqueId: String? = nil) {
        self.threadId = threadId
        self.participantIds = participantIds
        super.init(uniqueId: uniqueId)
    }
}
