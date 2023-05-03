//
// Chat+Threads.swift
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
    /// Get list of threads.
    /// - Parameters:
    ///   - request: The request of list of threads.
    ///   - completion: Response of list of threads that came with pagination.
    ///   - cacheResponse: Threads list that came from the cache?.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getThreads(_ request: ThreadsRequest, completion: @escaping CompletionType<[Conversation]>, cacheResponse: CacheResponseType<[Conversation]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .getThreads, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Conversation]>) in
            let threads = response.result
            let pagination = Pagination(hasNext: threads?.count ?? 0 >= request.count, count: request.count, offset: request.offset)
            completion(ChatResponse(uniqueId: response.uniqueId, result: threads, error: response.error, pagination: pagination))
        }
        cache?.conversation.fetch(request.fetchRequest) { [weak self] threads, totalCount in
            let threads = threads.map { $0.codable() }
            self?.responseQueue.async {
                let pagination = Pagination(hasNext: totalCount >= request.count, count: request.count, offset: request.offset)
                cacheResponse?(ChatResponse(uniqueId: request.uniqueId, result: threads, pagination: pagination))
            }
        }
    }

    /// Getting the all threads.
    /// - Parameters:
    ///   - request: If you send the summary true in request the result only contains list of all thread ids which is much faster way to fetch thread list.
    ///   - completion: Response of list of threads that came with pagination.
    ///   - cacheResponse: Thread cache return data from disk so it contains all data in each model.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getAllThreads(request: AllThreads, completion: @escaping CompletionType<[Int]>, cacheResponse: CacheResponseType<[Int]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .getThreads, uniqueIdResult: uniqueIdResult, completion: completion)
        cache?.conversation.fetchIds { [weak self] threadIds in
            self?.responseQueue.async {
                cacheResponse?(ChatResponse(uniqueId: request.uniqueId, result: threadIds, error: nil))
            }
        }
    }
}

// Response
extension Chat {
    func onThreads(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Conversation]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.threadsListChange(response)))
        cache?.conversation.insert(models: response.result ?? [])
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
