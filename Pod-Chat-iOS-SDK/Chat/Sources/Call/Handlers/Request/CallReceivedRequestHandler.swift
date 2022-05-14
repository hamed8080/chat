//
//  CallReceivedRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class CallReceivedRequestHandler {
    
    class func handle( _ req:CallReceivedRequest,
                       _ chat:Chat
    ){
        chat.prepareToSendAsync(clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode,
                                subjectId: req.callId,
                                messageType: .DELIVERED_CALL_REQUEST)
    }
}
