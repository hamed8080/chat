//
// StartCallRecordingRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class StartCallRecordingRequest: BaseRequest {
    let callId: Int

    public init(callId: Int, uniqueId: String? = nil) {
        self.callId = callId
        super.init(uniqueId: uniqueId)
    }
}
