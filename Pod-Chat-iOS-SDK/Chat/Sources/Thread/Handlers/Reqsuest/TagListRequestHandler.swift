//
//  TagListRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/3/21.
//

import Foundation
class TagListRequestHandler {
    
    class func handle( _ uniqueId:String? = nil,
                       _ chat:Chat,
                       _ completion: @escaping  CompletionType<[Tag]>,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(clientSpecificUniqueId: uniqueId,
                                messageType: .TAG_LIST,
                                uniqueIdResult: uniqueIdResult){ response in
            completion(response.result as? [Tag] , response.uniqueId, response.error )
        }
    }
    
}


