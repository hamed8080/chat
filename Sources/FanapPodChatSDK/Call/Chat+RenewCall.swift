//
// Chat+RenewCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// To renew  a call you could start request it by this method.
    /// - Parameters:
    ///   - request: The callId and list of the participants.
    ///   - completion: A created call with details.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func renewCallRequest(_ request: RenewCallRequest, _ completion: @escaping CompletionType<CreateCall>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onRenewCall(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<CreateCall> = asyncMessage.toChatResponse()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
