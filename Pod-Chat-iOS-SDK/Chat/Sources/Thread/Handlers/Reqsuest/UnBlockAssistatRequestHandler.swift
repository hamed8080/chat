//
//  UnBlockAssistatRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/23/21.
//

import Foundation
import FanapPodAsyncSDK

public class UnBlockAssistatRequestHandler  {
    
    class func handle( _ req:BlockUnblockAssistantRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<[Assistant]> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req.assistants,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType:.UNBLOCK_ASSISTANT,
                                uniqueIdResult: uniqueIdResult
        ){ response in
            completion(response.result as? [Assistant] ,response.uniqueId , response.error)
        }
    }
   
}
