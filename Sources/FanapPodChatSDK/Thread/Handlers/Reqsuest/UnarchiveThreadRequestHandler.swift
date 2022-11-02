//
//  UnarchiveThreadRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class UnarchiveThreadRequestHandler {
	
	class func handle( _ req:UnarchiveThreadRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<Int>,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								subjectId: req.threadId,
								messageType: .unarchiveThread,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Int , response.uniqueId, response.error)
        }
	}
}

	
