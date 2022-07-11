//
//  BlockContactRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation
import Contacts

class BlockContactRequestHandler {
    
    class func handle( _ req:BlockRequest ,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<BlockedContact> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType: .BLOCK,
                                uniqueIdResult: uniqueIdResult,
                                completion: { response in
                                    completion(response.result as? BlockedContact,response.uniqueId , response.error)
                                }
        )
    }
    
    
}
