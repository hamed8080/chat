//
// CallStartedResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class CallStartedResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else { return }

        guard var callStarted = try? JSONDecoder().decode(StartCall.self, from: data) else { return }
        callStarted.callId = chatMessage.subjectId
        chat.delegate?.chatEvent(event: .call(.callStarted(callStarted)))

        chat.callState = .started

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: callStarted))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .startCallRequest)
    }
}
