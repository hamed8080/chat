//
//  CancelCallRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class CancelCallRequestHandler {
    
    class func handle( _ req:CancelCallRequest,
                       _ chat:Chat,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req:req.call,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode,
                                subjectId: req.call.id,
                                messageType: .CANCEL_CALL,
                                uniqueIdResult: uniqueIdResult)
    }
}
