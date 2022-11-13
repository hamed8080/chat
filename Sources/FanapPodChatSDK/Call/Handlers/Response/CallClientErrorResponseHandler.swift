//
// CallClientErrorResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class CallClientErrorResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let callClientError = try? JSONDecoder().decode(CallError.self, from: data) else { return }
        chat.delegate?.chatEvent(event: .call(CallEventModel(type: .callClientError(callClientError))))

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: callClientError))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .callClientErrors)
    }
}