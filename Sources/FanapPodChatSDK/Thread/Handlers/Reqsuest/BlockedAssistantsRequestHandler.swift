//
// BlockedAssistantsRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

public class BlockedAssistantsRequestHandler {
    class func handle(_ req: BlockedAssistantsRequest,
                      _ chat: Chat,
                      _ completion: @escaping PaginationCompletionType<[Assistant]>,
                      _ cacheResponse: PaginationCacheResponseType<[Assistant]>? = nil,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(response.result as? [Assistant], response.uniqueId, pagination, response.error)
        }

        CacheFactory.get(useCache: cacheResponse != nil, cacheType: .getBlockedAssistants(req.count, req.offset)) { response in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: CMAssistant.crud.getTotalCount())
            cacheResponse?(response.cacheResponse as? [Assistant], response.uniqueId, pagination, nil)
        }
    }
}
