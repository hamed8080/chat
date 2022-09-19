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
        let contactIds = firstAddRequest.contactIds
        chat.prepareToSendAsync(req: contactIds ?? req,
                                clientSpecificUniqueId: firstAddRequest.uniqueId,
                                subjectId: firstAddRequest.threadId,
                                messageType: .ADD_PARTICIPANT,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Conversation , response.uniqueId, response.error )
        }
    }
}


