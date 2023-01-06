//
// Chat+Bots.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Get all user bots.
    /// - Parameters:
    ///   - request: Request if want to have different uniqueId.
    ///   - completion: List of user bots.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getUserBots(_ request: GetUserBotsRequest, completion: @escaping CompletionType<[BotInfo]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onBots(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[BotInfo]> = asyncMessage.toChatResponse(context: persistentManager.context)
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }

    func onBotMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<String?> = asyncMessage.toChatResponse(context: persistentManager.context)
        delegate?.chatEvent(event: .bot(.botMessage(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
