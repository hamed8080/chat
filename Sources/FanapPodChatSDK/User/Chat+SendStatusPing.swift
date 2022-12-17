//
// Chat+SendStatusPing.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Send Status ping.
    /// - Parameter request: Send type of ping.
    func sendStatusPing(_ request: SendStatusPingRequest) {
        prepareToSendAsync(req: request)
    }
}

// Response
extension Chat {
    func onStatusPing(_: AsyncMessage) {}
}
