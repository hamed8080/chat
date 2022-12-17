//
// Chat+CallsToJoin.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// A list of calls that is currnetly is running and you could join to them.
    /// - Parameters:
    ///   - request: List of threads that you are in and more filters.
    ///   - completion: List of joinable calls.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getCallsToJoin(_ request: GetJoinCallsRequest, _ completion: @escaping CompletionType<[Call]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onJoinCalls(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Call]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .call(.callsToJoin(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
