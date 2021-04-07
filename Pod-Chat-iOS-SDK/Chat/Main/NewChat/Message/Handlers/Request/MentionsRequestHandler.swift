//
//  MentionsRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class MentionsRequestHandler {
	
	class func handle( _ req:MentionRequest,
					   _ chat:Chat,
					   _ completion: @escaping PaginationCompletionType<[Message]> ,
                       _ cacheResponse: PaginationCacheResponseType<[Message]>? = nil,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								typeCode: req.typeCode ,
								subjectId: req.threadId,
								messageType: .GET_HISTORY,
                                uniqueIdResult: uniqueIdResult){ response in
            let pagination = Pagination(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(response.result as? [Message]  ,response.uniqueId , pagination, response.error)
        }
        
        CacheFactory.get(useCache: cacheResponse != nil ,  cacheType: .MENTIONS){ response in
            let predicate = NSPredicate(format: "threadId == %i", req.threadId)
            let pagination = Pagination(count: req.count, offset: req.offset, totalCount:CMMessage.crud.getTotalCount(predicate: predicate))
            cacheResponse?(response.cacheResponse as? [Message], response.uniqueId , pagination , nil)
        }
	}
}
