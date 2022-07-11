//
//  TerminateCallRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class TerminateCallRequestHandler {
    
    class func handle( _ req:TerminateCallRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<[CallParticipant]> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.callId,
                                messageType: .TERMINATE_CALL,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? [CallParticipant],response.uniqueId , response.error)
        }
    }
}
