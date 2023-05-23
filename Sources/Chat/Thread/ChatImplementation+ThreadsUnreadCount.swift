//
// ChatImplementation+ThreadsUnreadCount.swift
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
    /// Get list of threads.
    /// - Parameters:
    ///   - request: The request of list of threads.
    ///   - completion: Response of list of threads that came with pagination.
    ///   - cacheResponse: Threads list that came from the cache?.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getThreadsUnreadCount(_ request: ThreadsUnreadCountRequest, completion: @escaping CompletionType<[String: Int]>, cacheResponse: CacheResponseType<[String: Int]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .threadsUnreadCount, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[String: Int]>) in
            let threads = response.result
            completion(ChatResponse(uniqueId: response.uniqueId, result: threads, error: response.error))
        }

        cache?.conversation?.threadsUnreadcount(request.threadIds) { [weak self] threadsUnreadCount in
            self?.responseQueue.async {
                cacheResponse?(ChatResponse(uniqueId: request.uniqueId, result: threadsUnreadCount, error: nil))
            }
        }
    }
}

// Response
extension ChatImplementation {
    func onThreadsUnreadCount(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[String: Int]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.threadsUnreadCount(response)))
        cache?.conversation?.updateThreadsUnreadCount(response.result ?? [:])
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
