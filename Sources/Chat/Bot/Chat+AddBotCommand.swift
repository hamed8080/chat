//
// Chat+AddBotCommand.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension Chat {
    /// Add commands to a bot.
    /// - Parameters:
    ///   - request: The request that contains the name bot and list of commands.
    ///   - completion: The responser of the request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func addBotCommand(_ request: AddBotCommandRequest, completion: @escaping CompletionType<BotInfo>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .defineBotCommand, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onAddBotCommand(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<BotInfo> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .bot(.createBotCommand(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
