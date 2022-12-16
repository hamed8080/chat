//
// Chat+RemoveBotCommand.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestRemoveBotCommand(_ req: RemoveBotCommandRequest, _ completion: @escaping CompletionType<BotInfo>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onRemoveBotCommand(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let botInfo = try? JSONDecoder().decode(BotInfo.self, from: data) else { return }
        delegate?.chatEvent(event: .bot(.removeBotCommand(botInfo)))
        guard let callback: CompletionType<BotInfo> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: botInfo))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .removeBotCommands)
    }
}
