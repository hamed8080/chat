//
// Chat+CreateBot.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Create Bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot.
    ///   - completion: The responser of the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func createBot(_ request: CreateBotRequest, completion: @escaping CompletionType<Bot>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onCreateBot(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<BotInfo> = asyncMessage.toChatResponse(context: persistentManager.context)
        delegate?.chatEvent(event: .bot(.createBot(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
