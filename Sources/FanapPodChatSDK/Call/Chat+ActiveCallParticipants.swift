//
// Chat+ActiveCallParticipants.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// List of active call participants during the call.
    /// - Parameters:
    ///   - request: The callId of the call.
    ///   - completion: List of call participants that change during the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func activeCallParticipants(_ request: GeneralSubjectIdRequest, _ completion: CompletionType<[CallParticipant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .activeCallParticipants
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onActiveCallParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
