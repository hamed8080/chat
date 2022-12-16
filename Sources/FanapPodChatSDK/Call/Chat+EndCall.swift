//
// Chat+EndCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestEndCall(_ req: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .endCallRequest
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onCallEnded(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let callId = chatMessage.subjectId else { return }
        delegate?.chatEvent(event: .call(.callEnded(callId)))
        callState = .ended
        guard let callback: CompletionType<Int> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: callId))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .endCallRequest)
        webrtc?.clearResourceAndCloseConnection()
        webrtc = nil
    }
}
