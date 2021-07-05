//
//  CallsHistoryRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
class CallsHistoryRequestHandler {
    
    class func handle( _ req:CallsHistoryRequest,
                       _ chat:Chat,
                       _ completion: @escaping PaginationCompletionType<[Call]> ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req:req,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode,
                                messageType: .GET_CALLS,
                                uniqueIdResult: uniqueIdResult){ response in
            let calls = response.result as? [Call]
            let pagination = Pagination(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(calls ,response.uniqueId , pagination , response.error)
        }
    }
}
