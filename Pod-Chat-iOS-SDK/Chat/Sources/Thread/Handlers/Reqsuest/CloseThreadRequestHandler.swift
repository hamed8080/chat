//
//  CloseThreadRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class CloseThreadRequestHandler {
	
	class func handle( _ req:CloseThreadRequest ,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<Int> ,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		chat.prepareToSendAsync(req: nil,
								clientSpecificUniqueId: req.uniqueId,
								subjectId: req.threadId,
								messageType: .CLOSE_THREAD,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Int ,response.uniqueId , response.error)
        }
	}
}

	
