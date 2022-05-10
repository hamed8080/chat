//
//  UnMuteThreadRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class UnMuteThreadRequestHandler {
	
	class func handle( _ request:MuteUnmuteThreadRequest,
					   _ chat:Chat,
					   _ completion: @escaping CompletionType<Int> ,
					   _ uniqueIdResult:UniqueIdResultType = nil
	){
		
		chat.prepareToSendAsync(req: nil,
								clientSpecificUniqueId: request.uniqueId,
								typeCode: request.typeCode,
								subjectId: request.threadId ,
								messageType: .UNMUTE_THREAD,
                                uniqueIdResult: uniqueIdResult){ response in
            let unmuteResponse = response.result as? UnMuteThreadResponse
            completion(unmuteResponse?.threadId , response.uniqueId , response.error)
        }
	}
}

	
