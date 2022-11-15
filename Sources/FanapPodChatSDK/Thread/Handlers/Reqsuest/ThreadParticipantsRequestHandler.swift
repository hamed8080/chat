//
// ThreadParticipantsRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class ThreadParticipantsRequestHandler {
    class func handle(_ req: ThreadParticipantsRequest,
                      _ chat: Chat,
                      _ completion: @escaping PaginationCompletionType<[Participant]>,
                      _ cacheResponse: PaginationCacheResponseType<[Participant]>?,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(response.result as? [Participant], response.uniqueId, pagination, response.error)
        }

        CacheFactory.get(useCache: cacheResponse != nil, cacheType: .getThreadParticipants(req)) { response in
            let predicate = NSPredicate(format: "threadId == %i", req.threadId)
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: CMParticipant.crud.getTotalCount(predicate: predicate))
            cacheResponse?(response.cacheResponse as? [Participant], response.uniqueId, pagination, nil)
        }
    }
}
