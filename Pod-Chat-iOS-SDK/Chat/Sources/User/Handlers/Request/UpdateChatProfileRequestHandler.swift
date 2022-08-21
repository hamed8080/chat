//
//  UpdateChatProfileRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class UpdateChatProfileRequestHandler {
    
    class func handle(_ req:UpdateChatProfile,
                      _ chat:Chat,
                      _ completion: @escaping CompletionType<Profile> ,
                      _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType: .SET_PROFILE,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Profile,response.uniqueId , response.error)
        }
    }
}
