//
// Chat+TerminateCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestTerminateCall(_ req: GeneralSubjectIdRequest, _ completion: CompletionType<[CallParticipant]>? = nil, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .terminateCall
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}
