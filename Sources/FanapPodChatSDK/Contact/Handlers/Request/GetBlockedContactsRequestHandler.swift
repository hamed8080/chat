//
// GetBlockedContactsRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Contacts
import Foundation
class GetBlockedContactsRequestHandler {
    class func handle(_ req: BlockedListRequest,
                      _ chat: Chat,
                      _ completion: @escaping PaginationCompletionType<[BlockedContact]>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType: .getBlocked,
                                uniqueIdResult: uniqueIdResult) { response in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(response.result as? [BlockedContact], response.uniqueId, pagination, response.error)
        }

//    TODO: must ad to core data cache
//
        //		CacheFactory.get(chat:chat ,
        //						 useCache: cacheResponse != nil,
        //						 completion: { response in
//                            completion(response.cacheResponse as? [BlockedUser] , response.error)
//                         } ,
        //						 cacheType: .getBlockedUsers)
    }
}
