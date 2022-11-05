//
// GetThreadsRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class GetThreadsRequestHandler {
    class func handle(_ req: ThreadsRequest,
                      _ chat: Chat,
                      _ completion: @escaping PaginationCompletionType<[Conversation]>,
                      _ cacheResponse: PaginationCacheResponseType<[Conversation]>? = nil,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType: .getThreads,
                                uniqueIdResult: uniqueIdResult) { response in
            let threads = response.result as? [Conversation]
            let pagination = Pagination(hasNext: threads?.count ?? 0 >= req.count, count: req.count, offset: req.offset)
            completion(threads, response.uniqueId, pagination, response.error)
        }

        CacheFactory.get(useCache: cacheResponse != nil, cacheType: .getThreads(req)) { response in
            let cachedResponse = response.cacheResponse as? [Conversation]
            let pagination = Pagination(hasNext: cachedResponse?.count ?? 0 >= req.count, count: req.count, offset: req.offset)
            cacheResponse?(cachedResponse, response.uniqueId, pagination, nil)
        }
    }
}
