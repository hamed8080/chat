//
// MentionsRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class MentionsRequestHandler {
    class func handle(_ req: MentionRequest,
                      _ chat: Chat,
                      _ completion: @escaping PaginationCompletionType<[Message]>,
                      _ cacheResponse: PaginationCacheResponseType<[Message]>? = nil,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.threadId,
                                messageType: .getHistory,
                                uniqueIdResult: uniqueIdResult) { response in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(response.result as? [Message], response.uniqueId, pagination, response.error)
        }

        CacheFactory.get(useCache: cacheResponse != nil, cacheType: .mentions) { response in
            let predicate = NSPredicate(format: "threadId == %i", req.threadId)
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: CMMessage.crud.getTotalCount(predicate: predicate))
            cacheResponse?(response.cacheResponse as? [Message], response.uniqueId, pagination, nil)
        }
    }
}
