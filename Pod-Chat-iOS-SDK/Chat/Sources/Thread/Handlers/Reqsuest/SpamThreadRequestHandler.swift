//
//  SpamThreadRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class SpamThreadRequestHandler {
    
    class func handle( _ req : SpamThreadRequest,
                       _ chat:Chat,
                       _ completion:@escaping CompletionType<BlockedContact>  ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: nil ,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode ,
                                subjectId: req.threadId,
                                messageType: .SPAM_PV_THREAD,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? BlockedContact,response.uniqueId , response.error)
        }
        
    }
}


