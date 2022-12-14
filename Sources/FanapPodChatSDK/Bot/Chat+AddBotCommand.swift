//
// Chat+AddBotCommand.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestAddBotCommand(_ req: AddBotCommandRequest, _ completion: @escaping CompletionType<BotInfo>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onAddBotCommand(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let botInfo = try? JSONDecoder().decode(BotInfo.self, from: data) else { return }
        delegate?.chatEvent(event: .bot(.createBotCommand(botInfo)))
        guard let callback: CompletionType<BotInfo> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: botInfo))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .defineBotCommand)
    }
}
