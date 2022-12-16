//
// Chat+Bots.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestBots(_ req: GetUserBotsRequest, _ completion: @escaping CompletionType<[BotInfo]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onBots(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let callback: CompletionType<[BotInfo]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let userBots = try? JSONDecoder().decode([BotInfo].self, from: data) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: userBots))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .getUserBots)
    }

    func onBotMessage(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        delegate?.chatEvent(event: .bot(.botMessage(chatMessage.content)))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .botMessage)
    }
}
