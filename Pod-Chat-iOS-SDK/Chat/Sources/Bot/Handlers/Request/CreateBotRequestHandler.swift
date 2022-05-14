//
//  CreateBotRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class CreateBotRequestHandler {
	
	class func handle( _ req:CreateBotRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<Bot> ,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
        chat.prepareToSendAsync(req: req.botName,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode ,
                                plainText:true,
                                messageType: .CREATE_BOT,
                                uniqueIdResult: uniqueIdResult)
        { response in
            completion(response.result as? Bot ,response.uniqueId , response.error)
        }
    }
}
