//
//  GetTagThreadsRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class GetTagParticipantsRequestHandler {
    
    class func handle( _ req:GetTagParticipantsRequest ,
                       _ chat:Chat,
                       _ completion: @escaping  CompletionType<[Conversation]>,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode ,
                                subjectId: req.id,
                                messageType: .GET_TAG_PARTICIPANTS,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? [Conversation] , response.uniqueId, response.error )
        }
    }
    
}


