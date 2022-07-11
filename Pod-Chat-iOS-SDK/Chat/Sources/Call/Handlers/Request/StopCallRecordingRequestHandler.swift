//
//  StopCallRecordingRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class StopCallRecordingRequestHandler {
    
    class func handle( _ req:StopCallRecordingRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<Participant> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.callId,
                                messageType: .STOP_RECORDING,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Participant,response.uniqueId , response.error)
        }
    }
}
