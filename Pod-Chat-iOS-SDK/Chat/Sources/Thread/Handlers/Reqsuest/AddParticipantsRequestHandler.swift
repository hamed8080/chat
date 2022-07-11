//
//  AddParticipantsRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class AddParticipantsRequestHandler {
    
    class func handle( _ req:[AddParticipantRequest] ,
                       _ chat:Chat,
                       _ completion: @escaping  CompletionType<Conversation>,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        guard let firstAddRequest = req.first else {return}
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: firstAddRequest.uniqueId,
                                subjectId: firstAddRequest.threadId,
                                messageType: .ADD_PARTICIPANT,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Conversation , response.uniqueId, response.error )
        }
    }
    
    //may remove in future release and provide a substitution way and move request to Object model and class AddParticipantRequest
    class func handle( _ contactIds:[Int],
                       _ threadId:Int,
                       _ uniqueId:String,
                       _ chat:Chat,
                       _ completion: @escaping  CompletionType<Conversation>,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: contactIds,
                                clientSpecificUniqueId: uniqueId,
                                subjectId: threadId,
                                messageType: .ADD_PARTICIPANT,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Conversation , response.uniqueId, response.error )
        }
    }
}


