//
//  GetHistoryRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 3/5/21.
//

import Foundation
class GetHistoryRequestHandler {
    
    class func handle( _ req:GetHistoryRequest,
                       _ chat:Chat,
                       _ completion: @escaping PaginationCompletionType<[Message]>,
                       _ cacheResponse: CompletionType<[Message]>? = nil,
                       _ textMessageNotSentRequests: CompletionType<[SendTextMessageRequest]>? = nil,
                       _ editMessageNotSentRequests: CompletionType<[EditMessageRequest]>? = nil,
                       _ forwardMessageNotSentRequests: CompletionType<[ForwardMessageRequest]>? = nil,
                       _ fileMessageNotSentRequests: CompletionType<[(UploadFileRequest , SendTextMessageRequest )]>? = nil,
                       _ uploadFileNotSentRequests: CompletionType<[UploadFileRequest]>? = nil,
                       _ uploadImageNotSentRequests: CompletionType<[UploadImageRequest]>? = nil,
                       _ uniqueIdResult: UniqueIdResultType = nil
    ){
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.threadId,
                                messageType: .GET_HISTORY,
                                uniqueIdResult: uniqueIdResult){ response in
            let messages = response.result as? [Message]
            let pagination = Pagination(hasNext: messages?.count ?? 0 >= req.count, count: req.count, offset: req.offset)
            completion(messages, response.uniqueId, pagination, response.error)
            if req.readOnly == false{
                saveMessagesToCache(response.result as? [Message], cacheResponse)
            }
        }
        
        CacheFactory.get(useCache: cacheResponse != nil , cacheType: .GET_HISTORY(req)){ response in
            cacheResponse?(response.cacheResponse as? [Message]  , req.uniqueId, nil)
        }
        
        CacheFactory.get(useCache: textMessageNotSentRequests != nil , cacheType: .GET_TEXT_NOT_SENT_REQUESTS(req.threadId)){ response in
            textMessageNotSentRequests?(response.cacheResponse as? [SendTextMessageRequest]  , req.uniqueId , nil)
        }
        
        CacheFactory.get(useCache: editMessageNotSentRequests != nil , cacheType: .EDIT_MESSAGE_REQUESTS(req.threadId)){ response in
            editMessageNotSentRequests?(response.cacheResponse as? [EditMessageRequest] , req.uniqueId , nil)
        }
        
        CacheFactory.get(useCache: forwardMessageNotSentRequests != nil , cacheType: .FORWARD_MESSAGE_REQUESTS(req.threadId)){ response in
            forwardMessageNotSentRequests?(response.cacheResponse as? [ForwardMessageRequest]  , req.uniqueId , nil)
        }
        
        CacheFactory.get(useCache: fileMessageNotSentRequests != nil , cacheType: .FILE_MESSAGE_REQUESTS(req.threadId)){ response in
            forwardMessageNotSentRequests?(response.cacheResponse as? [ForwardMessageRequest]  , req.uniqueId , nil)
        }
        
        CacheFactory.get(useCache: uploadFileNotSentRequests != nil , cacheType: .UPLOAD_FILE_REQUESTS(req.threadId)){ response in
            forwardMessageNotSentRequests?(response.cacheResponse as? [ForwardMessageRequest]  , req.uniqueId , nil)
        }
        
        CacheFactory.get(useCache: uploadImageNotSentRequests != nil , cacheType: .UPLOAD_IMAGE_REQUESTS(req.threadId)){ response in
            forwardMessageNotSentRequests?(response.cacheResponse as? [ForwardMessageRequest]  , req.uniqueId , nil)
        }
    }
    
    class func saveMessagesToCache(_ messages:[Message]?, _ cacheResponse:CompletionType<[Message]>?){
        messages?.forEach({ message in
            CacheFactory.write(cacheType: .MESSAGE(message))
        })
        PSM.shared.save()
    }
}
