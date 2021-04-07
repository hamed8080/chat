//
//  UnBlockContactRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation
import Contacts

class UnBlockContactRequestHandler {
    
    class func handle( _ req:NewUnBlockRequest ,
                       _ chat:Chat,
                       _ completion: @escaping  CompletionType<BlockedUser>,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode ,
                                messageType: .UNBLOCK,
                                uniqueIdResult: uniqueIdResult) { response in
            let unblockResponse = response.result as? BlockUnblockResponse
            completion(unblockResponse?.blockedContact,response.uniqueId , response.error)
        }
        
    }
    
    
}
