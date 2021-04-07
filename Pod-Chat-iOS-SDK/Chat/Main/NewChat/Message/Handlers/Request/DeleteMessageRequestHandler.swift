//
//  DeleteMessageRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class DeleteMessageRequestHandler {
	
	class func handle( _ req:NewDeleteMessageRequest,
					   _ chat:Chat,
					   _ completion:@escaping CompletionType<DeleteMessage>,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								typeCode: req.typeCode ,
								subjectId: req.messageId,
								messageType: .DELETE_MESSAGE,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? DeleteMessage ,response.uniqueId , response.error)
        }
	}
}
