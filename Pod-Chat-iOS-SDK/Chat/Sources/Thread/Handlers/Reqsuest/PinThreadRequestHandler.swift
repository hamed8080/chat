//
//  PinThreadRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class PinThreadRequestHandler {
	
	class func handle( _ request:PinUnpinThreadRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<Int>,
					   _ uniqueIdResult: UniqueIdResultType = nil
	){
		
		chat.prepareToSendAsync(req: nil,
								clientSpecificUniqueId: request.uniqueId,
								subjectId: request.threadId ,
								messageType: .PIN_THREAD,
                                uniqueIdResult: uniqueIdResult){ response in
            let pinResponse = response.result as? PinThreadResponse
            completion(pinResponse?.threadId,response.uniqueId , response.error)
        }
	}
}

	
