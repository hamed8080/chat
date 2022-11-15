//
// GetHistoryRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class GetHistoryRequestHandler {
    class func handle(_ req: GetHistoryRequest,
                      _ chat: Chat,
                      _ completion: @escaping PaginationCompletionType<[Message]>,
                      _ cacheResponse: CompletionType<[Message]>? = nil,
                      _ textMessageNotSentRequests: CompletionType<[SendTextMessageRequest]>? = nil,
                      _ editMessageNotSentRequests: CompletionType<[EditMessageRequest]>? = nil,
                      _ forwardMessageNotSentRequests: CompletionType<[ForwardMessageRequest]>? = nil,
                      _ fileMessageNotSentRequests: CompletionType<[(UploadFileRequest, SendTextMessageRequest)]>? = nil,
                      _ uploadFileNotSentRequests: CompletionType<[UploadFileRequest]>? = nil,
                      _ uploadImageNotSentRequests: CompletionType<[UploadImageRequest]>? = nil,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            let messages = response.result as? [Message]
            let pagination = Pagination(hasNext: messages?.count ?? 0 >= req.count, count: req.count, offset: req.offset)
            completion(messages, response.uniqueId, pagination, response.error)
            if req.readOnly == false {
                saveMessagesToCache(response.result as? [Message], cacheResponse)
            }
        }

        CacheFactory.get(useCache: cacheResponse != nil, cacheType: .getHistory(req)) { response in
            cacheResponse?(response.cacheResponse as? [Message], req.uniqueId, nil)
        }

        CacheFactory.get(useCache: textMessageNotSentRequests != nil, cacheType: .getTextNotSentRequests(req.threadId)) { response in
            textMessageNotSentRequests?(response.cacheResponse as? [SendTextMessageRequest], req.uniqueId, nil)
        }

        CacheFactory.get(useCache: editMessageNotSentRequests != nil, cacheType: .editMessageRequests(req.threadId)) { response in
            editMessageNotSentRequests?(response.cacheResponse as? [EditMessageRequest], req.uniqueId, nil)
        }

        CacheFactory.get(useCache: forwardMessageNotSentRequests != nil, cacheType: .forwardMessageRequests(req.threadId)) { response in
            forwardMessageNotSentRequests?(response.cacheResponse as? [ForwardMessageRequest], req.uniqueId, nil)
        }

        CacheFactory.get(useCache: fileMessageNotSentRequests != nil, cacheType: .fileMessageRequests(req.threadId)) { response in
            forwardMessageNotSentRequests?(response.cacheResponse as? [ForwardMessageRequest], req.uniqueId, nil)
        }

        CacheFactory.get(useCache: uploadFileNotSentRequests != nil, cacheType: .uploadFileRequests(req.threadId)) { response in
            forwardMessageNotSentRequests?(response.cacheResponse as? [ForwardMessageRequest], req.uniqueId, nil)
        }

        CacheFactory.get(useCache: uploadImageNotSentRequests != nil, cacheType: .uploadImageRequests(req.threadId)) { response in
            forwardMessageNotSentRequests?(response.cacheResponse as? [ForwardMessageRequest], req.uniqueId, nil)
        }
    }

    class func saveMessagesToCache(_ messages: [Message]?, _: CompletionType<[Message]>?) {
        messages?.forEach { message in
            CacheFactory.write(cacheType: .message(message))
        }
        PSM.shared.save()
    }
}
