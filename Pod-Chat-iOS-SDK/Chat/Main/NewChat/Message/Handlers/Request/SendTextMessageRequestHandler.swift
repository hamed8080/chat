//
//  SendTextMessageRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/5/21.
//

import Foundation
class SendTextMessageRequestHandler {
    
    class func handle( _ req:NewSendTextMessageRequest,
                       _ chat:Chat,
                       _ onSent:  OnSentType ,
                       _ onSeen:  OnSeenType ,
                       _ onDeliver:  OnDeliveryType ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req                    : req.textMessage,
                                clientSpecificUniqueId : req.uniqueId,
                                typeCode               : req.typeCode,
                                subjectId              : req.threadId,
                                plainText              : true,
                                messageType            : .MESSAGE,
                                messageMessageType     : req.messageType,
                                metadata               : req.metadata,
                                systemMetadata         : req.systemMetadata,
                                repliedTo              : req.repliedTo,
                                uniqueIdResult         : uniqueIdResult,
                                completion             : nil,
                                onSent                 : onSent,
                                onDelivered            : onDeliver,
                                onSeen                 : onSeen)
        CacheFactory.write(cacheType: .SEND_TXET_MESSAGE_QUEUE(req))
        PSM.shared.save()
    }
}
