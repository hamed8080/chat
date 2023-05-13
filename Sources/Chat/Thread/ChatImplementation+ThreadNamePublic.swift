//
// ChatImplementation+ThreadNamePublic.swift
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
    /// Check name for the public thread is not occupied.
    /// - Parameters:
    ///   - request: The request for the name of the thread to check.
    ///   - completion: If thread name is free for using as public it will not be nil.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func isThreadNamePublic(_ request: IsThreadNamePublicRequest, completion: @escaping CompletionType<PublicThreadNameAvailableResponse>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .isNameAvailable, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension ChatImplementation {
    func onIsThreadNamePublic(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<PublicThreadNameAvailableResponse> = asyncMessage.toChatResponse()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
