//
// MuteCallRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class MuteCallRequest: BaseRequest {
    let callId: Int
    let userIds: [Int]

    public init(callId: Int, userIds: [Int], uniqueId: String? = nil) {
        self.callId = callId
        self.userIds = userIds
        super.init(uniqueId: uniqueId)
    }
}
