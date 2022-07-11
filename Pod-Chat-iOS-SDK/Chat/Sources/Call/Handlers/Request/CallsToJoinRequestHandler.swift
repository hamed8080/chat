//
//  CallsToJoinRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class CallsToJoinRequestHandler {
	
	class func handle( _ req:GetJoinCallsRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<[Call]> ,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								messageType: .GET_CALLS_TO_JOIN,
								uniqueIdResult: uniqueIdResult){ response in
			completion(response.result as? [Call],response.uniqueId , response.error)
		}
	}
	
}
