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
        guard let token = chat.config?.token else {return}
        
        let sendChatMessageVO = NewSendChatMessageVO(type:  ChatMessageVOTypes.FORWARD_MESSAGE.intValue(),
                                                     token: token,
                                                     content: "\(req.messageIds)",
                                                     subjectId: req.threadId,
                                                     typeCode:req.typeCode,
                                                     uniqueId: "\(req.uniqueIds)")
        req.uniqueIds.forEach { uniqueId in
            chat.callbacksManager.addCallback(uniqueId: uniqueId, callback: nil, onSent: onSent, onDelivered: onDeliver, onSeen: onSeen)
        }
        chat.prepareToSendAsync(sendChatMessageVO, uniqueId: req.uniqueId)
        CacheFactory.write(cacheType: .FORWARD_MESSAGE_QUEUE(req))
        PSM.shared.save()
    }
}
