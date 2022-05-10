//
//  JoinPublicThreadRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class JoinPublicThreadRequestHandler {
	
	class func handle( _ req:JoinPublicThreadRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<Conversation> ,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
        chat.prepareToSendAsync(req: req.threadName,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode,
                                plainText: true,
                                messageType:.JOIN_THREAD,
                                uniqueIdResult: uniqueIdResult
        ){ response in
            completion(response.result as? Conversation ,response.uniqueId , response.error)
        }
	}
}

	
