//
// SendCallClientErrorRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestSendCallError(_ req: CallClientErrorRequest, _ completion: @escaping CompletionType<CallError>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onCallError(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let callClientError = try? JSONDecoder().decode(CallError.self, from: data) else { return }
        delegate?.chatEvent(event: .call(.callClientError(callClientError)))
        guard let callback: CompletionType<CallError> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: callClientError))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .callClientErrors)
    }
}
