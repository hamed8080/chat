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

        chat.prepareToSendAsync(req                    : req.textMessage,
                                clientSpecificUniqueId : req.uniqueId,
                                typeCode               : req.typeCode,
                                subjectId              : req.messageId,
                                plainText              : true,
                                messageType            : .EDIT_MESSAGE,
                                messageMessageType     : req.messageType,
                                metadata               : req.metadata,
                                repliedTo              : req.repliedTo,
                                uniqueIdResult         : uniqueIdResult){ response in
            completion?(response.result as? Message ,response.uniqueId , response.error)
        }
        CacheFactory.write(cacheType: .EDIT_MESSAGE_QUEUE(req))
        PSM.shared.save()
    }
}
