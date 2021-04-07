//
//  ChangeThreadTypeRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class ChangeThreadTypeRequestHandler {
    
    class func handle( _ req:ChangeThreadTypeRequest ,
                       _ chat:Chat,
                       _ completion: @escaping  CompletionType<Conversation>,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode ,
                                subjectId: req.threadId,
                                messageType: .CHANGE_THREAD_TYPE,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Conversation , response.uniqueId, response.error)
        }
    }
}


