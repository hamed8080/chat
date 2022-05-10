//
//  ClearHistoryRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class ClearHistoryRequestHandler {
    
    class func handle( _ req:ClearHistoryRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<Int>,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: nil,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode ,
                                subjectId: req.threadId,
                                messageType: .CLEAR_HISTORY,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Int , response.uniqueId , response.error )
        }
    }
}
