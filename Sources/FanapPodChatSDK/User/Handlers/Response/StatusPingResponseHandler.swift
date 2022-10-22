//
// StatusPingResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class StatusPingResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        if chat.callbacksManager.getCallBack(chatMessage.uniqueId) == nil { return }
        if chatMessage.content?.data(using: .utf8) == nil { return }
        // no need to call callback
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .statusPing)
    }
}
