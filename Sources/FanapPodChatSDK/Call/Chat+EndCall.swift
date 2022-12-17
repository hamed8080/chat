//
// Chat+EndCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// To terminate a call.
    /// - Parameters:
    ///   - request: A request with a callId to finish the current call.
    ///   - completion: A callId that shows a call has terminated properly.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func endCall(_ request: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .endCallRequest
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onCallEnded(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        callState = .ended
        delegate?.chatEvent(event: .call(.callEnded(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
        webrtc?.clearResourceAndCloseConnection()
        webrtc = nil
    }
}
