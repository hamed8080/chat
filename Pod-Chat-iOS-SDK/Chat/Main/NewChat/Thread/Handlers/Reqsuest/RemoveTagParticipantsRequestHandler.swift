//
//  RemoveThreadFromTagRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class RemoveTagParticipantsRequestHandler {
    
    class func handle( _ req:RemoveTagParticipantsRequest ,
                       _ chat:Chat,
                       _ completion: @escaping  CompletionType<[TagParticipant]>,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req.tagParticipants,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode ,
                                subjectId: req.tagId,
                                messageType: .REMOVE_TAG_PARTICIPANTS,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? [TagParticipant] , response.uniqueId, response.error )
        }
    }
    
}


