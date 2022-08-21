//
//  GetAssistantsHistoryRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 2/23/21.
//

import Foundation
import FanapPodAsyncSDK

public class GetAssistantsHistoryRequestHandler  {
    
    class func handle( _ chat:Chat,
                       _ completion: @escaping CompletionType<[AssistantAction]> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        let req = BaseRequest()
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType:.GET_ASSISTANT_HISTORY,
                                uniqueIdResult: uniqueIdResult
        ){ response in
            completion(response.result as? [AssistantAction] ,response.uniqueId , response.error)
        }
    }
   
}
