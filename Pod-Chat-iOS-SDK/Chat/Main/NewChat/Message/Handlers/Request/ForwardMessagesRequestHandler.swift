//
//  ForwardMessagesRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/10/21.
//

import Foundation
class ForwardMessagesRequestHandler {
    
    class func handle( _ req:NewForwardMessageRequest,
                       _ chat:Chat,
                       _ onSent:OnSentType = nil ,
                       _ onSeen:OnSeenType = nil,
                       _ onDeliver:OnDeliveryType = nil,
                       _ uniqueIdsResult:UniqueIdsResultType = nil
    ){
        
        uniqueIdsResult?(req.uniqueIds) //do not remove this line it use batch uniqueIds
        
        chat.prepareToSendAsync(req                    : "\(req.messageIds)",
                                clientSpecificUniqueId : "\(req.uniqueIds)",
                                typeCode               : req.typeCode,
                                subjectId              : req.threadId,
                                plainText              : true,
                                messageType            : .FORWARD_MESSAGE,
                                uniqueIdResult         : nil,
                                completion             : nil,
                                onSent                 : onSent,
                                onDelivered            : onDeliver,
                                onSeen                 : onSeen)
        
        
        req.uniqueIds.forEach { uniqueId in
            chat.callbacksManager.addCallback(uniqueId: uniqueId, requesType: .FORWARD_MESSAGE, callback: nil, onSent: onSent, onDelivered: onDeliver, onSeen: onSeen)
        }
        CacheFactory.write(cacheType: .FORWARD_MESSAGE_QUEUE(req))
        PSM.shared.save()
    }
}
