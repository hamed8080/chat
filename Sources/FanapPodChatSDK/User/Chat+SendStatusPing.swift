//
// Chat+SendStatusPing.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestSendStatusPing(_ req: SendStatusPingRequest) {
        prepareToSendAsync(req: req)
    }
}

// Response
extension Chat {
    func onStatusPing(_: AsyncMessage) {}
}
