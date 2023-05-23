//
// ChatImplementation+AllUnreadMessageCount.swift
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
public extension ChatImplementation {
    /// Get the number of unread message count.
    /// - Parameters:
    ///   - request: The request can contain property to aggregate mute threads unread count.
    ///   - completion: The number of unread message count.
    ///   - cacheResponse: The number of unread message count in cache?.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func allUnreadMessageCount(_ request: AllThreadsUnreadCountRequest, completion: @escaping CompletionType<Int>, cacheResponse: CacheResponseType<Int>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .allUnreadMessageCount, uniqueIdResult: uniqueIdResult, completion: completion)
        cache?.conversation?.allUnreadCount { allUnreadCount in
            cacheResponse?(ChatResponse(uniqueId: request.uniqueId, result: allUnreadCount, error: nil))
        }
    }
}

// Response
extension ChatImplementation {
    func onUnreadMessageCount(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
