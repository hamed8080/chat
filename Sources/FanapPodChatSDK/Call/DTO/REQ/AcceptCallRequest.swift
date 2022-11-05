//
// AcceptCallRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class AcceptCallRequest: BaseRequest {
    let client: SendClient
    let callId: Int

    public init(callId: Int, client: SendClient, uniqueId: String? = nil) {
        self.callId = callId
        self.client = client
        super.init(uniqueId: uniqueId)
    }
}
