//
// CancelCallRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class CancelCallRequest: BaseRequest {
    let call: Call

    public init(call: Call, uniqueId: String? = nil) {
        self.call = call
        super.init(uniqueId: uniqueId)
    }
}
