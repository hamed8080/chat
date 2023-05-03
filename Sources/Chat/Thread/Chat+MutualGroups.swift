//
// Chat+MutualGroups.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension Chat {
    /// A list of mutual groups with a user.
    /// - Parameters:
    ///   - request: A request that contains a detail of a user invtee.
    ///   - completion: List of threads that are mutual between the current user and desired user.
    ///   - cacheResponse: The cached version of mutual groups.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func mutualGroups(_ request: MutualGroupsRequest, _ completion: @escaping CompletionType<[Conversation]>, cacheResponse: CacheResponseType<[Conversation]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .mutualGroups, uniqueIdResult: uniqueIdResult) { [weak self] (response: ChatResponse<[Conversation]>) in
            let pagination = PaginationWithContentCount(hasNext: response.result?.count ?? 0 >= request.count, count: request.count, offset: request.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))

            // insert to mutual cache only for this method beacuse we need request and id and idType to be cache
            self?.cache?.mutualGroup.insert(response.result ?? [], idType: request.toBeUserVO.inviteeTypes, mutualId: request.toBeUserVO.id)
        }

        cache?.mutualGroup.mutualGroups(request.toBeUserVO.id) { [weak self] mutuals in
            let threads = mutuals.first?.conversations?.allObjects.compactMap { $0 as? CDConversation }.map { $0.codable() }
            self?.responseQueue.async {
                let pagination = PaginationWithContentCount(hasNext: threads?.count ?? 0 >= request.count, count: request.count, offset: request.offset, totalCount: mutuals.count)
                cacheResponse?(ChatResponse(uniqueId: request.uniqueId, result: threads, error: nil, pagination: pagination))
            }
        }
    }
}

// Response
extension Chat {
    func onMutalGroups(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Conversation]> = asyncMessage.toChatResponse()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
