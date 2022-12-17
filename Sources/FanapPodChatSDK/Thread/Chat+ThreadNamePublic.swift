//
// Chat+ThreadNamePublic.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Check name for the public thread is not occupied.
    /// - Parameters:
    ///   - request: The request for the name of the thread to check.
    ///   - completion: If thread name is free for using as public it will not be nil.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func isThreadNamePublic(_ request: IsThreadNamePublicRequest, completion: @escaping CompletionType<String>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onIsThreadNamePublic(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<PublicThreadNameAvailableResponse> = asyncMessage.toChatResponse()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
