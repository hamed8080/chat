//
//  UserBotsBotsRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class UserBotsBotsRequestHandler {
	
	class func handle( _ req:GetUserBotsRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<[BotInfo]> ,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								typeCode: req.typeCode ,
								messageType: .GET_USER_BOTS,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? [BotInfo],response.uniqueId , response.error)
        }
	}
}
