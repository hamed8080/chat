//
//  RenewCallRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class RenewCallRequestHandler {
    
    class func handle( _ req:RenewCallRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<CreateCall>,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req.invitess,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.callId,
                                messageType: .RENEW_CALL_REQUEST,
                                uniqueIdResult: uniqueIdResult)
        { response in
            completion(response.result as? CreateCall, response.uniqueId, response.error)
        }
    }
}
