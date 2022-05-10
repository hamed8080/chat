//
//  GetBlockedContactsRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation
import Contacts
class GetBlockedContactsRequestHandler {

	class func handle( _ req:BlockedListRequest ,
					   _ chat:Chat,
					   _ completion: @escaping PaginationCompletionType<[BlockedUser]>,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								typeCode: req.typeCode ,
								messageType: .GET_BLOCKED,
                                uniqueIdResult: uniqueIdResult){response in
            let pagination = Pagination(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(response.result as? [BlockedUser] , response.uniqueId , pagination , response.error)
        }
        
//    TODO: must ad to core data cache
//
//		CacheFactory.get(chat:chat ,
//						 useCache: cacheResponse != nil,
//						 completion: { response in
//                            completion(response.cacheResponse as? [BlockedUser] , response.error)
//                         } ,
//						 cacheType: .GET_BLOCKED_USERS)
	}
	
}
