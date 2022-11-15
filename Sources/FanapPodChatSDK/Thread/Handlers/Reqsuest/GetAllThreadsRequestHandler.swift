//
// GetAllThreadsRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class GetAllThreadsRequestHandler {
    class func handle(_ req: AllThreads,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<[Conversation]>,
                      _ cacheResponse: CacheResponseType<[Conversation]>? = nil,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            let threads = response.result as? [Conversation]
            completion(threads, response.uniqueId, response.error)
        }

        CacheFactory.get(useCache: cacheResponse != nil, cacheType: .allThreads) { response in
            cacheResponse?(response.cacheResponse as? [Conversation], response.uniqueId, nil)
        }
    }
}
