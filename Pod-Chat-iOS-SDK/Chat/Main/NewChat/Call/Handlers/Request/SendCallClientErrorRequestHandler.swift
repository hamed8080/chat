//
//  SendCallClientErrorRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class SendCallClientErrorRequestHandler {
    
    class func handle( _ req:CallClientErrorRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<CallError> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req:req,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode,
                                subjectId: req.callId,
                                messageType: .CALL_CLIENT_ERRORS,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? CallError,response.uniqueId , response.error)
        }
    }
}
