//
//  DeleteThreadRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class DeleteThreadRequestHandler {
	
	class func handle( _ req:DeleteThreadRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<Int>,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								subjectId: req.threadId,
								messageType: .DELETE_THREAD,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Int , response.uniqueId, response.error)
        }
	}
}

	
