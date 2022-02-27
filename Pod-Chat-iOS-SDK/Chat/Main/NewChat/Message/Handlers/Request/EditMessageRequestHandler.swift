//
//  EditMessageRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/10/21.
//

import Foundation
class EditMessageRequestHandler {
    
    class func handle( _ req:NewEditMessageRequest,
                       _ chat:Chat,
                       _ completion:CompletionType<Message>? = nil,
                       _ uniqueIdResult: UniqueIdResultType  = nil
    ){
        guard let token = chat.config?.token else {return}
        let sendChatMessageVO = NewSendChatMessageVO(type:  ChatMessageVOTypes.EDIT_MESSAGE.intValue(),
                                                     token: token,
                                                     content:  req.textMessage,
                                                     messageType: req.messageType.rawValue,
                                                     metadata: req.metadata,
                                                     repliedTo: req.repliedTo,
                                                     subjectId: req.messageId,
                                                     typeCode:req.typeCode,
                                                     uniqueId: req.uniqueId)
        
        chat.prepareToSendAsync(sendChatMessageVO, uniqueId: req.uniqueId , uniqueIdResult: uniqueIdResult){ response in
            completion?(response.result as? Message ,response.uniqueId , response.error)
        }
        CacheFactory.write(cacheType: .EDIT_MESSAGE_QUEUE(req))
        PSM.shared.save()
    }
}
