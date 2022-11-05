//
// RenewCallRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class RenewCallRequest: BaseRequest {
    let invitess: [Invitee]
    let callId: Int

    public init(invitees: [Invitee], callId: Int, uniqueId: String? = nil) {
        invitess = invitees
        self.callId = callId
        super.init(uniqueId: uniqueId)
    }
}
