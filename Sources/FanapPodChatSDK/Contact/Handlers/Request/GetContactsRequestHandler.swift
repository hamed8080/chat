//
// GetContactsRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Contacts
import Foundation
class GetContactsRequestHandler {
    class func handle(_ req: ContactsRequest,
                      _ chat: Chat,
                      _ completion: @escaping PaginationCompletionType<[Contact]>,
                      _ cacheResponse: PaginationCacheResponseType<[Contact]>? = nil,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType: .getContacts,
                                uniqueIdResult: uniqueIdResult) { response in
            let pagination = PaginationWithContentCount(count: req.size, offset: req.offset, totalCount: response.contentCount)
            completion(response.result as? [Contact], response.uniqueId, pagination, response.error)
        }

        CacheFactory.get(useCache: cacheResponse != nil, cacheType: .getCashedContacts(req)) { cacheContacts in
            let pagination = PaginationWithContentCount(count: req.size, offset: req.offset, totalCount: CMContact.crud.getTotalCount())
            cacheResponse?(cacheContacts.cacheResponse as? [Contact], req.uniqueId, pagination, cacheContacts.error)
        }
    }
}
