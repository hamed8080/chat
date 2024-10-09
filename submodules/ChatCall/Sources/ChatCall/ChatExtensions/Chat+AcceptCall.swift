//
// Chat+AcceptCall.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import Chat
import ChatDTO
import ChatCore

// Request
public extension ChatImplementation {
    /// Accept a received call.
    /// - Parameters:
    ///   - request: The request that contains a callId and how do you want to answer the call as an example with audio or video.
    func acceptCall(_ request: AcceptCallRequest) {
        prepareToSendAsync(req: request, type: .acceptCall)
    }
}
