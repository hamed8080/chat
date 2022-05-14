//
//  GetAllThreadsRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class GetAllThreadsRequestHandler {
	
	class func handle( _ req:AllThreads ,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<[Conversation]> ,
                       _ cacheResponse: CacheResponseType<[Conversation]>? = nil,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								typeCode: req.typeCode ,
								messageType: .GET_THREADS,
								uniqueIdResult: uniqueIdResult){ response in
            let threads = response.result as? [Conversation]
            completion(threads ,response.uniqueId , response.error)
        }
		
        CacheFactory.get(useCache: cacheResponse != nil , cacheType: .ALL_THREADS){ response in
            cacheResponse?(response.cacheResponse as? [Conversation] ,response.uniqueId , nil)
        }
	}
}

	
