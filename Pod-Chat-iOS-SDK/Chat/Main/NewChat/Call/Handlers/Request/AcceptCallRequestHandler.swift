//
//  AcceptCallRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class AcceptCallRequestHandler {
    
    class func handle( _ req:EndCallRequest,
                       _ chat:Chat,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode,
                                subjectId: req.callId,
                                messageType: .ACCEPT_CALL,
                                uniqueIdResult: uniqueIdResult)
    }
}
