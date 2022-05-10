//
//  DeleteTagRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class DeleteTagRequestHandler {
    
    class func handle( _ req:DeleteTagRequest ,
                       _ chat:Chat,
                       _ completion: @escaping  CompletionType<Tag>,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode ,
                                subjectId: req.id,
                                messageType: .DELETE_TAG,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? Tag , response.uniqueId, response.error )
        }
    }
    
}


