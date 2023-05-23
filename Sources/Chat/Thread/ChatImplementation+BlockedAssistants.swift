//
// ChatImplementation+BlockedAssistants.swift
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
    /// Get list of blocked assistants.
    /// - Parameters:
    ///   - request: A request that contains an offset and count.
    ///   - completion: List of blocked assistants.
    ///   - cacheResponse: The cached version of blocked assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getBlockedAssistants(_ request: BlockedAssistantsRequest, completion: @escaping CompletionType<[Assistant]>, cacheResponse: CacheResponseType<[Assistant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .blockedAssistnts, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Assistant]>) in
            let pagination = PaginationWithContentCount(hasNext: response.result?.count ?? 0 >= request.count, count: request.count, offset: request.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }

        cache?.assistant?.getBlocked(request.count, request.offset) { [weak self] assistants, totalCount in
            let assistants = assistants.map(\.codable)
            self?.responseQueue.async {
                let pagination = PaginationWithContentCount(hasNext: assistants.count >= request.count, count: request.count, offset: request.offset, totalCount: totalCount)
                cacheResponse?(ChatResponse(uniqueId: request.uniqueId, result: assistants, pagination: pagination))
            }
        }
    }
}

// Response
extension ChatImplementation {
    func onGetBlockedAssistants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse()
        cache?.assistant?.insert(models: response.result ?? [])
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
