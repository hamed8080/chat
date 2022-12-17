//
// Chat+CancelCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// The cancelation of a call when nobody answer the call or somthing different happen.
    /// - Parameters:
    ///   - request: A call that you want to cancel a call.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func cancelCall(_ request: CancelCallRequest, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult)
    }
}

// Response
extension Chat {
    func onCancelCall(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Call> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callCanceled(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }

    func onGroupCallCanceled(_ asyncMessage: AsyncMessage) {
        var response: ChatResponse<CancelGroupCall> = asyncMessage.toChatResponse()
        response.result?.callId = response.subjectId
        delegate?.chatEvent(event: .call(.groupCallCanceled(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
