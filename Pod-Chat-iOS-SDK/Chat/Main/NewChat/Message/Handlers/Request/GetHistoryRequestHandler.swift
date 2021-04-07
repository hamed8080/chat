//
//  GetHistoryRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/5/21.
//

import Foundation
class GetHistoryRequestHandler {
    
    class func handle( _ req:NewGetHistoryRequest,
                       _ chat:Chat,
                       _ completion: @escaping PaginationCompletionType<[Message]>,
                       _ cacheResponse: CompletionType<[Message]>? = nil,
                       _ textMessageNotSentRequests: CompletionType<[NewSendTextMessageRequest]>? = nil,
                       _ editMessageNotSentRequests: CompletionType<[NewEditMessageRequest]>? = nil,
                       _ forwardMessageNotSentRequests: CompletionType<[NewForwardMessageRequest]>? = nil,
                       _ fileMessageNotSentRequests: CompletionType<[(NewUploadFileRequest , NewSendTextMessageRequest )]>? = nil,
                       _ uploadFileNotSentRequests: CompletionType<[NewUploadFileRequest]>? = nil,
                       _ uploadImageNotSentRequests: CompletionType<[NewUploadImageRequest]>? = nil,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                typeCode: req.typeCode ,
                                subjectId: req.threadId,
                                messageType: .GET_HISTORY,
                                uniqueIdResult: uniqueIdResult){ response in
            let pagination = Pagination(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(response.result as? [Message] ,response.uniqueId , pagination , response.error)
        }
        
        CacheFactory.get(useCache: cacheResponse != nil , cacheType: .GET_HISTORY(req)){ response in
            cacheResponse?(response.cacheResponse as? [Message]  , req.uniqueId, nil)
        }
        
        CacheFactory.get(useCache: textMessageNotSentRequests != nil , cacheType: .GET_TEXT_NOT_SENT_REQUESTS(req.threadId)){ response in
            textMessageNotSentRequests?(response.cacheResponse as? [NewSendTextMessageRequest]  , req.uniqueId , nil)
        }
        
        CacheFactory.get(useCache: editMessageNotSentRequests != nil , cacheType: .EDIT_MESSAGE_REQUESTS(req.threadId)){ response in
            editMessageNotSentRequests?(response.cacheResponse as? [NewEditMessageRequest] , req.uniqueId , nil)
        }
        
        CacheFactory.get(useCache: forwardMessageNotSentRequests != nil , cacheType: .FORWARD_MESSAGE_REQUESTS(req.threadId)){ response in
            forwardMessageNotSentRequests?(response.cacheResponse as? [NewForwardMessageRequest]  , req.uniqueId , nil)
        }
        
        CacheFactory.get(useCache: fileMessageNotSentRequests != nil , cacheType: .FILE_MESSAGE_REQUESTS(req.threadId)){ response in
            forwardMessageNotSentRequests?(response.cacheResponse as? [NewForwardMessageRequest]  , req.uniqueId , nil)
        }
        
        CacheFactory.get(useCache: uploadFileNotSentRequests != nil , cacheType: .UPLOAD_FILE_REQUESTS(req.threadId)){ response in
            forwardMessageNotSentRequests?(response.cacheResponse as? [NewForwardMessageRequest]  , req.uniqueId , nil)
        }
        
        CacheFactory.get(useCache: uploadImageNotSentRequests != nil , cacheType: .UPLOAD_IMAGE_REQUESTS(req.threadId)){ response in
            forwardMessageNotSentRequests?(response.cacheResponse as? [NewForwardMessageRequest]  , req.uniqueId , nil)
        }
    }
}
