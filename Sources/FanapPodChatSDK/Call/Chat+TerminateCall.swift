//
// Chat+TerminateCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Terminate the call completely for all the participants at once if you have access to it.
    /// - Parameters:
    ///   - request: The callId of the call to terminate.
    ///   - completion: List of call participants that change during the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func terminateCall(_ request: GeneralSubjectIdRequest, _ completion: CompletionType<[CallParticipant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .terminateCall
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}
