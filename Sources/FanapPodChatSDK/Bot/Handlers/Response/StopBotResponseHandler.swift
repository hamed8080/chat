//
// StopBotResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class StopBotResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let botName = chatMessage.content else { return }
        chat.delegate?.chatEvent(event: .bot(.stopBot(botName)))

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: botName))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .stopBot)
    }
}
