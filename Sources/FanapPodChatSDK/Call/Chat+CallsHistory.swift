//
// Chat+CallsHistory.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// List of the call history.
    /// - Parameters:
    ///   - request: The request that contains offset and count and some other filters.
    ///   - completion: List of calls.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func callsHistory(_ request: CallsHistoryRequest, _ completion: @escaping CompletionType<[Call]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Call]>) in
            let pagination = PaginationWithContentCount(hasNext: response.result?.count ?? 0 >= request.count, count: request.count, offset: request.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
    }
}

// Response
extension Chat {
    func onCallsHistory(_ asyncMessage: AsyncMessage) {
        var response: ChatResponse<[Call]> = asyncMessage.toChatResponse()
        response.contentCount = asyncMessage.chatMessage?.contentCount
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
