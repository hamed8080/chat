//
// BotMessageResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class BotMessageResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance
        chat.delegate?.chatEvent(event: .bot(.botMessage(chatMessage.content)))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .botMessage)
    }
}
