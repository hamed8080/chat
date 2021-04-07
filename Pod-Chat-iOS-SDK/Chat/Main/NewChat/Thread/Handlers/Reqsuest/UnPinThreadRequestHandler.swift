//
//  UnPinThreadRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class UnPinThreadRequestHandler {
    
    class func handle( _ request:NewPinUnpinThreadRequest,
                       _ chat:Chat,
                       _ completion: @escaping CompletionType<Int>,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        
        chat.prepareToSendAsync(req: nil,
                                clientSpecificUniqueId: request.uniqueId,
                                typeCode: request.typeCode,
                                subjectId: request.threadId ,
                                messageType: .UNPIN_THREAD,
                                uniqueIdResult: uniqueIdResult){ response in
            let pinResponse = response.result as? PinThreadResponse
            completion(pinResponse?.threadId ,response.uniqueId , response.error)
        }
    }
}


