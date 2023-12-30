//
// Chat+ThreadsUnreadCount.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Get list of threads.
    /// - Parameters:
    ///   - request: The request of list of threads.
    ///   - completion: Response of list of threads that came with pagination.
    ///   - cacheResponse: Threads list that came from the cache?.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getThreadsUnreadCount(_ request: ThreadsUnreadCountRequest, completion: @escaping CompletionType<[String: Int]>, cacheResponse: CacheResponseType<[String: Int]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[String: Int]>) in
            let threads = response.result
            completion(ChatResponse(uniqueId: response.uniqueId, result: threads, error: response.error, typeCode: response.typeCode))
        }
    }
}

// Response
extension Chat {
    func onThreadsUnreadCount(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[String: Int]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.threadsUnreadCount(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
