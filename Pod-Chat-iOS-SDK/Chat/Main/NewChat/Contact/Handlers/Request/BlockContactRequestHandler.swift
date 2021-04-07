//
//  BlockContactRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/17/21.
//

import Foundation
import Contacts

class BlockContactRequestHandler {
    
    class func handle( _ req:NewBlockRequest ,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<BlockedUser> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode ,
                                messageType: .BLOCK,
                                uniqueIdResult: uniqueIdResult,
                                completion: { response in
                                    let  blockResponse = response.result as? BlockUnblockResponse
                                    completion(blockResponse?.blockedContact,response.uniqueId , response.error)
                                }
        )
    }
    
    
}
