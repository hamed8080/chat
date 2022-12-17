//
// Chat+AcceptCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

// Request
public extension Chat {
    /// Accept a received call.
    /// - Parameters:
    ///   - request: The request that contains a callId and how do you want to answer the call as an example with audio or video.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func acceptCall(_ request: AcceptCallRequest, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult)
    }
}
