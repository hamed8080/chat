//
// EndCallResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class EndCallResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance
        guard let callId = chatMessage.subjectId else { return }
        chat.delegate?.chatEvent(event: .call(CallEventModel(type: .callEnded(callId))))
        chat.callState = .ended
        chat.callbacksManager.callEndDelegate?(callId, chatMessage.uniqueId)
    }
}
