//
//  PinMessageRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class PinMessageRequestHandler {
	
	class func handle( _ req:PinUnpinMessageRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<PinUnpinMessage> ,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								typeCode: req.typeCode ,
								subjectId: req.messageId,
								messageType: .PIN_MESSAGE,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? PinUnpinMessage , response.uniqueId ,response.error)
        }
	}
}