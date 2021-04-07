//
//  UserInfoRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class UserInfoRequestHandler {
	
	class func handle(_ req:UserInfoRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<User>,
                       _ cacheResponse: CacheResponseType<User>? = nil,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: nil,
								clientSpecificUniqueId: req.uniqueId,
								typeCode: req.typeCode ,
								messageType: .USER_INFO,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? User , response.uniqueId , response.error)
        }
        CacheFactory.get(useCache: cacheResponse != nil, cacheType: .USER_INFO){ response in
            cacheResponse?(response.cacheResponse as? User , response.uniqueId, nil)
        }
	}
}
