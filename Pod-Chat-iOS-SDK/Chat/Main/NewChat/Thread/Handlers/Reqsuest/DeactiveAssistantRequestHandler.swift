//
//  DeactiveAssistantRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/23/21.
//

import Foundation
import FanapPodAsyncSDK

public class DeactiveAssistantRequestHandler  {
    
    class func handle( _ req:DeactiveAssistantRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<[Assistant]> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req.assistants,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode,
                                messageType:.DEACTICVE_ASSISTANT,
                                uniqueIdResult: uniqueIdResult
        ){ response in
            completion(response.result as? [Assistant] ,response.uniqueId , response.error)
        }
    }
   
}
