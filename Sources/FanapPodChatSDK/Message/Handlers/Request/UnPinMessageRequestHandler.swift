//
//  PinMessageRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class UnPinMessageRequestHandler {
    
    class func handle( _ req:PinUnpinMessageRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<PinUnpinMessage> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.messageId,
                                messageType: .UNPIN_MESSAGE,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? PinUnpinMessage , response.uniqueId , response.error)
        }
    }
}
