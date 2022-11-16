//
// MutualGroupsRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class MutualGroupsRequestHandler {
    class func handle(_ req: MutualGroupsRequest,
                      _ chat: Chat,
                      _ completion: @escaping PaginationCompletionType<[Conversation]>,
                      _ cacheResponse: PaginationCacheResponseType<[Conversation]>? = nil,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(response.result as? [Conversation], response.uniqueId, pagination, response.error)

            // insert to mutual cache only for this method beacuse we need request and id and idType to be cache
            if let conversations = response.result as? [Conversation] {
                CacheFactory.write(cacheType: .mutualGroups(conversations, req))
                CacheFactory.save()
            }
        }

        CacheFactory.get(useCache: cacheResponse != nil, cacheType: .getMutualGroups(req)) { response in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: CMMutualGroup.crud.getTotalCount())
            cacheResponse?(response.cacheResponse as? [Conversation], response.uniqueId, pagination, nil)
        }
    }
}
