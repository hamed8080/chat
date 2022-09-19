//
//  AddBotCommandRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class AddBotCommandRequestHandler {
	
	class func handle( _ req:AddBotCommandRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<BotInfo> ,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								messageType: .DEFINE_BOT_COMMAND,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? BotInfo,response.uniqueId , response.error)
        }
	}
}
