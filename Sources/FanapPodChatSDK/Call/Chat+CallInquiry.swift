//
// Chat+CallInquiry.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// To get the status of the call and participants after a disconnect or when you need it.
    /// - Parameters:
    ///   - request: The callId.
    ///   - completion: A created call with details.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func callInquery(_ request: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<[CallParticipant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .callInquiry
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onCallInquiry(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[CallParticipant]> = asyncMessage.toChatResponse()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
