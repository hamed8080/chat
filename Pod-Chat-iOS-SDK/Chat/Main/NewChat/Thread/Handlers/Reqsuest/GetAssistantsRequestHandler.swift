//
//  GetAssistantsRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/23/21.
//

import Foundation
import FanapPodAsyncSDK

public class GetAssistantsRequestHandler  {
    
    class func handle( _ req:AssistantsRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<[Assistant]> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode,
                                messageType:.GET_ASSISTANTS,
                                uniqueIdResult: uniqueIdResult
        ){ response in
            completion(response.result as? [Assistant] ,response.uniqueId , response.error)
        }
    }
    
}
