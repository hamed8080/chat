//
//  StartCallGroupRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class StartCallGroupRequestHandler {
    
    class func handle( _ req:StartCallRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<CreateCall> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode ,
                                messageType: .GROUP_CALL_REQUEST,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? CreateCall,response.uniqueId , response.error)
        }
    }
}
