//
//  AddCallParticipantRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class AddCallParticipantRequestHandler {
    
    class func handle( _ req:AddCallParticipantsRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<[CallParticipant]> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.callId,
                                messageType: .ADD_CALL_PARTICIPANT,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? [CallParticipant],response.uniqueId , response.error)
        }
    }
}
