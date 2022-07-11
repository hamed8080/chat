//
//  StartCallRecordingRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class StartCallRecordingRequestHandler {
    
    class func handle( _ req:StartCallRecordingRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<Participant> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.callId,
                                messageType: .START_RECORDING,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Participant,response.uniqueId , response.error)
        }
    }
}
