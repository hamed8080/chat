//
//  ThreadParticipantsRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class ThreadParticipantsRequestHandler {
	
	class func handle( _ req:ThreadParticipantsRequest,
					   _ chat:Chat,
					   _ completion: @escaping PaginationCompletionType<[Participant]> ,
                       _ cacheResponse: PaginationCacheResponseType<[Participant]>? ,
					   _ uniqueIdResult:UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								subjectId: req.threadId,
								messageType: .THREAD_PARTICIPANTS,
                                uniqueIdResult: uniqueIdResult){ response in
            let pagination = Pagination(count: req.count, offset: req.offset , totalCount: response.contentCount)
            completion(response.result as? [Participant]  , response.uniqueId , pagination , response.error)
        }
        
        CacheFactory.get(useCache: cacheResponse != nil , cacheType: .GET_THREAD_PARTICIPANTS(req)){ response in
            let predicate = NSPredicate(format: "threadId == %i", req.threadId)
            let pagination = Pagination(count: req.count, offset: req.offset, totalCount: CMParticipant.crud.getTotalCount(predicate: predicate))
            cacheResponse?(response.cacheResponse as? [Participant] , response.uniqueId , pagination, nil)
        }
	}
}
