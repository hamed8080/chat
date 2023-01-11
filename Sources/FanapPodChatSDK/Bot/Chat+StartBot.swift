//
// Chat+StartBot.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat { /// Start a bot.
    /// - Parameters:
    ///   - request: The request with threadName and a threadId.
    ///   - completion: Name of a bot if it starts successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func startBot(_ request: StartStopBotRequest, completion: @escaping CompletionType<String>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    /// Stop a bot.
    /// - Parameters:
    ///   - request: The request with threadName and a threadId.
    ///   - completion: Name of a bot if it stopped successfully.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func stopBot(_ request: StartStopBotRequest, completion: @escaping CompletionType<String>, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .stopBot
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onStartStopBot(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<String> = asyncMessage.toChatResponse()
        if asyncMessage.chatMessage?.type == .startBot {
            delegate?.chatEvent(event: .bot(.startBot(response)))
        } else {
            delegate?.chatEvent(event: .bot(.stopBot(response)))
        }
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
