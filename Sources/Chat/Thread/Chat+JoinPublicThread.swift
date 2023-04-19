//
// Chat+JoinPublicThread.swift
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
    /// Join to a public thread.
    /// - Parameters:
    ///   - request: Thread name of public thread.
    ///   - completion: Detail of public thread as a ``Conversation`` object.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func joinThread(_ request: JoinPublicThreadRequest, completion: @escaping CompletionType<Conversation>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onJoinThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
