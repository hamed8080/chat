//
// CallCanceledResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class CallCanceledResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let call = try? JSONDecoder().decode(Call.self, from: data) else { return }
        chat.delegate?.chatEvent(event: .call(CallEventModel(type: .callCanceled(call))))
        chat.callbacksManager.callRejectedDelegate?(call, chatMessage.uniqueId)
    }
}
