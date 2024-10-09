//
// Chat+TerminateCall.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import Chat
import ChatDTO
import ChatCore
import ChatModels

// Request
public extension ChatImplementation {
    /// Terminate the call completely for all the participants at once if you have access to it.
    /// - Parameters:
    ///   - request: The callId of the call to terminate.
    func terminateCall(_ request: GeneralSubjectIdRequest) {
        prepareToSendAsync(req: request, type: .terminateCall)
    }
}
