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
        guard let token = chat.createChatModel?.token else {return}
        
        let sendChatMessageVO = NewSendChatMessageVO(type:  ChatMessageVOTypes.FORWARD_MESSAGE.intValue(),
                                                     token: token,
                                                     content: "\(req.messageIds)",
                                                     subjectId: req.threadId,
                                                     typeCode:req.typeCode,
                                                     uniqueId: "\(req.uniqueIds)",
                                                     isCreateThreadAndSendMessage: false)
        req.uniqueIds.forEach { uniqueId in
            chat.callbacksManager.addCallback(uniqueId: uniqueId, callback: nil, onSent: onSent, onDelivered: onDeliver, onSeen: onSeen)
        }
        chat.prepareToSendAsync(sendChatMessageVO, uniqueId: req.uniqueId ?? UUID().uuidString)
        CacheFactory.write(cacheType: .FORWARD_MESSAGE_QUEUE(req))
        PSM.shared.save()
    }
}
