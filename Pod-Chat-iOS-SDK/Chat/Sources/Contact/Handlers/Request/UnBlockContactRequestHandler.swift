//
//  UnBlockContactRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation
import Contacts

class UnBlockContactRequestHandler {
    
    class func handle( _ req:UnBlockRequest ,
                       _ chat:Chat,
                       _ completion: @escaping  CompletionType<BlockedContact>,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode ,
                                messageType: .UNBLOCK,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? BlockedContact,response.uniqueId , response.error)
        }
        
    }
    
    
}
