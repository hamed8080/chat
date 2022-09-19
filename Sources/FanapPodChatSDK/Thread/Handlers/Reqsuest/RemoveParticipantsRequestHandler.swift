//
//  RemoveParticipantsRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class RemoveParticipantsRequestHandler {
    
    class func handle( _ req : RemoveParticipantsRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<[Participant]> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req.participantIds ,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.threadId,
                                messageType: .REMOVE_PARTICIPANT,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? [Participant]  , response.uniqueId , response.error)
        }
    }
}


