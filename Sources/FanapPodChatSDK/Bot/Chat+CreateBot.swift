//
// Chat+CreateBot.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestCreateBot(_ req: CreateBotRequest, _ completion: @escaping CompletionType<Bot>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onCreateBot(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let bot = try? JSONDecoder().decode(Bot.self, from: data) else { return }
        delegate?.chatEvent(event: .bot(.createBot(bot)))
        guard let callback: CompletionType<Bot> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: bot))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .createBot)
    }
}
