//
// Chat+ClearHistory.swift
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
    /// Clear all messages inside a thread for user.
    /// - Parameters:
    ///   - request: The request that  contains a threadId.
    ///   - completion: A threadId if the result was a success.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func clearHistory(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .clearHistory
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onClearHistory(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        cache?.message.clearHistory(threadId: response.result ?? -1)
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
