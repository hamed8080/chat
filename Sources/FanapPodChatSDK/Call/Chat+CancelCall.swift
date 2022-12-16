//
// Chat+CancelCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestCancelCall(_ req: CancelCallRequest, _ uniqueIdResult: UniqueIdResultType? = nil) {
        callState = .canceled
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult)
    }
}

// Response
extension Chat {
    func onCancelCall(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let call = try? JSONDecoder().decode(Call.self, from: data) else { return }
        delegate?.chatEvent(event: .call(.callCanceled(call)))
        guard let callback: CompletionType<Call> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: call))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .cancelCall)
    }

    func onGroupCallCanceled(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard var cancelGroupCall = try? JSONDecoder().decode(CancelGroupCall.self, from: data) else { return }
        cancelGroupCall.callId = chatMessage.subjectId
        delegate?.chatEvent(event: .call(.groupCallCanceled(cancelGroupCall)))
        guard let callback: CompletionType<CancelGroupCall> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: cancelGroupCall))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .cancelGroupCall)
    }
}
