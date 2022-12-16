//
// Chat+StartBot.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestStartBot(_ req: StartStopBotRequest, _ completion: @escaping CompletionType<String>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    func requestStopBot(_ req: StartStopBotRequest, _ completion: @escaping CompletionType<String>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .stopBot
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onStartStopBot(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let botName = chatMessage.content else { return }
        if chatMessage.type == .startBot {
            delegate?.chatEvent(event: .bot(.startBot(botName)))
        } else {
            delegate?.chatEvent(event: .bot(.stopBot(botName)))
        }
        guard let callback: CompletionType<String> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: botName))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .startBot)
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .stopBot)
    }
}
