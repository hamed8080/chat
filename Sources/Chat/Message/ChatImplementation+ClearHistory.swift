//
// ChatImplementation+ClearHistory.swift
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
    /// Clear all messages inside a thread for user.
    /// - Parameters:
    ///   - request: The request that  contains a threadId.
    ///   - completion: A threadId if the result was a success.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func clearHistory(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Int>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .clearHistory, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension ChatImplementation {
    func onClearHistory(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        cache?.message?.clearHistory(threadId: response.result ?? -1)
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
