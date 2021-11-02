//
//  RejectCallRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class RejectCallRequestHandler {
    
    class func handle( _ req:RejectCallRequest,
                       _ chat:Chat,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req:req.call,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode,
                                subjectId: req.call.id,
                                messageType: .REJECT_CALL,
                                uniqueIdResult: uniqueIdResult)
    }
}
