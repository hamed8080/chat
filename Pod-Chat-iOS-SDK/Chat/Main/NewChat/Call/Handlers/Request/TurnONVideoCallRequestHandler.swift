//
//  TurnONVideoCallRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class TurnONVideoCallRequestHandler {
    
    class func handle( _ req:TurnOnVideoCallRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<[CallParticipant]> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode,
                                subjectId: req.callId,
                                messageType: .TURN_ON_VIDEO_CALL,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? [CallParticipant],response.uniqueId , response.error)
        }
    }
}
