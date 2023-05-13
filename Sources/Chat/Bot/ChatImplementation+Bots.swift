//
// ChatImplementation+Bots.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension ChatImplementation {
    /// Get all user bots.
    /// - Parameters:
    ///   - request: Request if want to have different uniqueId.
    ///   - completion: List of user bots.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getUserBots(_ request: GetUserBotsRequest, completion: @escaping CompletionType<[BotInfo]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .getUserBots, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension ChatImplementation {
    func onBots(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[BotInfo]> = asyncMessage.toChatResponse()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }

    func onBotMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<String?> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .bot(.botMessage(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
