//
//  DeleteMessageRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class DeleteMessageRequestHandler {
	
	class func handle( _ req:DeleteMessageRequest,
					   _ chat:Chat,
					   _ completion:@escaping CompletionType<Message>,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								subjectId: req.messageId,
								messageType: .DELETE_MESSAGE,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Message ,response.uniqueId , response.error)
        }
	}
}
