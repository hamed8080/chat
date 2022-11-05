//
// AllUnreadMessageCountRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class AllUnreadMessageCountRequestHandler {
    class func handle(_ req: UnreadMessageCountRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Int>,
                      _ cacheResponse: CacheResponseType<Int>? = nil,
                      _ uniqueIdResult: ((String) -> Void)? = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType: .allUnreadMessageCount,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? Int, response.uniqueId, response.error)
        }

        CacheFactory.get(useCache: cacheResponse != nil, cacheType: .allUnreadCount) { response in
            cacheResponse?(response.cacheResponse as? Int, response.uniqueId, nil)
        }
    }
}
