//
// Chat+BlockedAssistants.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Get list of blocked assistants.
    /// - Parameters:
    ///   - request: A request that contains an offset and count.
    ///   - completion: List of blocked assistants.
    ///   - cacheResponse: The cached version of blocked assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getBlockedAssistants(_ request: BlockedAssistantsRequest, _ completion: @escaping CompletionType<[Assistant]>, cacheResponse: CacheResponseType<[Assistant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Assistant]>) in
            let pagination = PaginationWithContentCount(count: request.count, offset: request.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }

        let response = cache?.assistant?.getBlocked(request.count, request.offset)
        let pagination = PaginationWithContentCount(count: request.count, offset: request.offset, totalCount: response?.totalCount)
        cacheResponse?(ChatResponse(uniqueId: request.uniqueId, result: response?.objects.map(\.codable), error: nil, pagination: pagination))
    }
}

// Response
extension Chat {
    func onGetBlockedAssistants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse()
        cache?.assistant?.insert(models: response.result ?? [])
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
