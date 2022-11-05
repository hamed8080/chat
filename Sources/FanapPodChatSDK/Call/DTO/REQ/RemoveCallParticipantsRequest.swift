//
// RemoveCallParticipantsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class RemoveCallParticipantsRequest: BaseRequest {
    let callId: Int
    var userIds: [Int]

    public init(callId: Int, userIds: [Int], uniqueId: String? = nil) {
        self.callId = callId
        self.userIds = userIds
        super.init(uniqueId: uniqueId)
    }

    override public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        if userIds.count > 0 {
            try? container.encode(userIds)
        }
    }
}
