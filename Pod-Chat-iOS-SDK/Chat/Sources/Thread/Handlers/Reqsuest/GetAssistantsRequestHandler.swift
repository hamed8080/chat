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
                       _ completion: @escaping PaginationCompletionType<[Assistant]> ,
                       _ cacheResponse: PaginationCompletionType<[Assistant]>? = nil ,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode,
                                messageType:.GET_ASSISTANTS,
                                uniqueIdResult: uniqueIdResult
        ){ response in
            let pagination = Pagination(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(response.result as? [Assistant] ,response.uniqueId , pagination , response.error)
        }
        
        CacheFactory.get(useCache: cacheResponse != nil , cacheType: .GET_ASSISTANTS(req.count, req.offset)){ response in
            let pagination = Pagination(count: req.count, offset: req.offset, totalCount: CMAssistant.crud.getTotalCount())
            cacheResponse?(response.cacheResponse as? [Assistant] ,response.uniqueId , pagination , nil)
        }
    }
    
}
