//
//  IsThreadNamePublicRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class IsThreadNamePublicRequestHandler {
	
	class func handle( _ req:IsThreadNamePublicRequest ,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<String> ,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								messageType: .IS_NAME_AVAILABLE,
                                uniqueIdResult: uniqueIdResult){ response in
            let threadNameResponse = response.result as? PublicThreadNameAvailableResponse
            completion(threadNameResponse?.name ,response.uniqueId , response.error)
        }
	}
}

	
