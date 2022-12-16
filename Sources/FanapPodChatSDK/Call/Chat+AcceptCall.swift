//
// Chat+AcceptCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

// Request
extension Chat {
    func requestAcceptCall(_ req: AcceptCallRequest, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult)
    }
}
