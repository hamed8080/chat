//
//  MuteThreadRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class MuteThreadRequestHandler {
	
	class func handle( _ req:MuteUnmuteThreadRequest ,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<Int>,
					   _ uniqueIdResult:UniqueIdResultType = nil
	){
		
		chat.prepareToSendAsync(req: req,
								clientSpecificUniqueId: req.uniqueId,
								subjectId: req.threadId,
								messageType: .MUTE_THREAD,
                                uniqueIdResult: uniqueIdResult){ response in
            let muteThreadResponse = response.result as? MuteThreadResponse
            completion(muteThreadResponse?.threadId , response.uniqueId, response.error)
        }
	}
}

	
