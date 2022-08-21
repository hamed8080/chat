//
//  AllUnreadMessageCountRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class AllUnreadMessageCountRequestHandler {
	
	class func handle( _ req:UnreadMessageCountRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<Int> ,
                       _ cacheResponse: CacheResponseType<Int>? = nil,
					   _ uniqueIdResult: ((String)->())? = nil
	){
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								messageType: .ALL_UNREAD_MESSAGE_COUNT,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Int,response.uniqueId , response.error)
        }
        
        CacheFactory.get(useCache: cacheResponse != nil ,  cacheType: .ALL_UNREAD_COUNT){ response in
            cacheResponse?(response.cacheResponse as? Int , response.uniqueId , nil)
        }
	}
}
