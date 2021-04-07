//
//  CreateThreadRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class CreateThreadRequestHandler {
    
    class func handle( _ req:NewCreateThreadRequest ,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<Conversation> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode ,
                                messageType: .CREATE_THREAD,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Conversation  , response.uniqueId , response.error )
        }
    }
}


