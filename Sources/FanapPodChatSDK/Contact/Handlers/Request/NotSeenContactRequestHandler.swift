//
//  NotSeenContactRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class NotSeenContactRequestHandler{
	class func handle( _ req:NotSeenDurationRequest ,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<[UserLastSeenDuration]> ,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								messageType: .GET_NOT_SEEN_DURATION,
								uniqueIdResult: uniqueIdResult,
								completion: { response in
                                    let contactNotSeenDusrationresponse = response.result as? ContactNotSeenDurationRespoonse
                                    completion(contactNotSeenDusrationresponse?.notSeenDuration ,response.uniqueId , response.error)
                                }
		)
	}
}
