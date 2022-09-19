//
//  CurrentUserRolesRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class CurrentUserRolesRequestHandler {
	
	class func handle( _ req:CurrentUserRolesRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<[Roles]> ,
                       _ cacheResponse: CacheResponseType<[Roles]>? = nil,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: nil,
								clientSpecificUniqueId: req.uniqueId,
								subjectId: req.threadId,
								messageType: .GET_CURRENT_USER_ROLES,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? [Roles] , response.uniqueId , response.error)
        }
        
        CacheFactory.get(useCache: cacheResponse != nil, cacheType: .CUREENT_USER_ROLES(req.threadId)){ response in
            cacheResponse?(response.cacheResponse as? [Roles] , req.uniqueId , nil)
        }
	}
}
