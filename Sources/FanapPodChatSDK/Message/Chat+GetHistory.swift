//
// Chat+GetHistory.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestGetHistory(_ req: GetHistoryRequest,
                           _ completion: @escaping CompletionType<[Message]>,
                           _ cacheResponse: CacheResponseType<[Message]>? = nil,
                           _ textMessageNotSentRequests: CompletionTypeNoneDecodeable<[SendTextMessageRequest]>? = nil,
                           _ editMessageNotSentRequests: CompletionTypeNoneDecodeable<[EditMessageRequest]>? = nil,
                           _ forwardMessageNotSentRequests: CompletionTypeNoneDecodeable<[ForwardMessageRequest]>? = nil,
                           _ fileMessageNotSentRequests: CompletionTypeNoneDecodeable<[(UploadFileRequest, SendTextMessageRequest)]>? = nil,
                           _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { [weak self] (response: ChatResponse<[Message]>) in
            let messages = response.result
            let pagination = Pagination(hasNext: messages?.count ?? 0 >= req.count, count: req.count, offset: req.offset)
            completion(ChatResponse(uniqueId: response.uniqueId, result: messages, error: response.error, pagination: pagination))
            if req.readOnly == false {
                self?.saveMessagesToCache(messages, cacheResponse)
            }
        }

        cache.get(useCache: cacheResponse != nil, cacheType: .getHistory(req), completion: cacheResponse)

        cache.get(useCache: textMessageNotSentRequests != nil, cacheType: .getTextNotSentRequests(req.threadId)) { (response: ChatResponse<[SendTextMessageRequest]>) in
            textMessageNotSentRequests?(ChatResponse(uniqueId: req.uniqueId, result: response.result, error: response.error))
        }

        cache.get(useCache: editMessageNotSentRequests != nil, cacheType: .editMessageRequests(req.threadId)) { response in
            editMessageNotSentRequests?(ChatResponse(uniqueId: req.uniqueId, result: response.result, error: response.error))
        }

        cache.get(useCache: forwardMessageNotSentRequests != nil, cacheType: .forwardMessageRequests(req.threadId)) { (response: ChatResponse<[ForwardMessageRequest]>) in
            forwardMessageNotSentRequests?(ChatResponse(uniqueId: req.uniqueId, result: response.result, error: response.error))
        }

        cache.get(useCache: fileMessageNotSentRequests != nil, cacheType: .fileMessageRequests(req.threadId)) { (response: ChatResponse<[(UploadFileRequest, SendTextMessageRequest)]>) in
            fileMessageNotSentRequests?(ChatResponse(uniqueId: req.uniqueId, result: response.result, error: response.error))
        }
    }

    func saveMessagesToCache(_ messages: [Message]?, _: CompletionType<[Message]>?) {
        messages?.forEach { message in
            cache.write(cacheType: .message(message))
            cache.write(cacheType: .deleteQueue(message.uniqueId ?? ""))
        }
        cache.save()
    }
}

// Response
extension Chat {
    func onGetHistroy(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let callback: CompletionType<[Message]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let history = try? JSONDecoder().decode([Message].self, from: data) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: history, contentCount: chatMessage.contentCount ?? 0))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .getHistory)
    }
}
