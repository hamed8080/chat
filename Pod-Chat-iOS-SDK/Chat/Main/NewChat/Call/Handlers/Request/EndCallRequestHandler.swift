//
//  EndCallRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class EndCallRequestHandler {
    
    class func handle( _ req:EndCallRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<Int> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: nil,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode,
                                subjectId: req.callId,
                                messageType: .END_CALL_REQUEST,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Int,response.uniqueId , response.error)
        }
    }
}
