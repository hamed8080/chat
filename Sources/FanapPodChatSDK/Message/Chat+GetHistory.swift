//
// Chat+GetHistory.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Get list of messages inside a thread.
    /// - Parameters:
    ///   - request: The threadId and other filter properties.
    ///   - completion: The response which can contains llist of messages.
    ///   - cacheResponse: The cache response.
    ///   - textMessageNotSentRequests: A list of messages that failed to sent.
    ///   - editMessageNotSentRequests: A list of edit messages that failed to sent.
    ///   - forwardMessageNotSentRequests: A list of forward messages that failed to sent.
    ///   - fileMessageNotSentRequests: A list of file messages that failed to sent.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getHistory(_ request: GetHistoryRequest,
                    completion: @escaping CompletionType<[Message]>,
                    cacheResponse: CacheResponseType<[Message]>? = nil,
                    textMessageNotSentRequests: CompletionTypeNoneDecodeable<[SendTextMessageRequest]>? = nil,
                    editMessageNotSentRequests: CompletionTypeNoneDecodeable<[EditMessageRequest]>? = nil,
                    forwardMessageNotSentRequests: CompletionTypeNoneDecodeable<[ForwardMessageRequest]>? = nil,
                    fileMessageNotSentRequests: CompletionTypeNoneDecodeable<[(UploadFileRequest, SendTextMessageRequest)]>? = nil,
                    uniqueIdResult: UniqueIdResultType? = nil)
    {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult) { [weak self] (response: ChatResponse<[Message]>) in
            let messages = response.result
            let pagination = Pagination(hasNext: messages?.count ?? 0 >= request.count, count: request.count, offset: request.offset)
            completion(ChatResponse(uniqueId: response.uniqueId, result: messages, error: response.error, pagination: pagination))
            if request.readOnly == false {
                self?.saveMessagesToCache(messages, cacheResponse)
            }
        }

        cache?.get(cacheType: .getHistory(request), completion: cacheResponse)

        cache?.get(cacheType: .getTextNotSentRequests(request.threadId)) { (response: ChatResponse<[SendTextMessageRequest]>) in
            textMessageNotSentRequests?(ChatResponse(uniqueId: request.uniqueId, result: response.result, error: response.error))
        }

        cache?.get(cacheType: .editMessageRequests(request.threadId)) { response in
            editMessageNotSentRequests?(ChatResponse(uniqueId: request.uniqueId, result: response.result, error: response.error))
        }

        cache?.get(cacheType: .forwardMessageRequests(request.threadId)) { (response: ChatResponse<[ForwardMessageRequest]>) in
            forwardMessageNotSentRequests?(ChatResponse(uniqueId: request.uniqueId, result: response.result, error: response.error))
        }

        cache?.get(cacheType: .fileMessageRequests(request.threadId)) { (response: ChatResponse<[(UploadFileRequest, SendTextMessageRequest)]>) in
            fileMessageNotSentRequests?(ChatResponse(uniqueId: request.uniqueId, result: response.result, error: response.error))
        }
    }

    /// Get list of messages with hashtags.
    /// - Parameters:
    ///   - request: A request that containst a threadId and hashtag name.
    ///   - completion: The response of messages.
    ///   - cacheResponse: The cache response.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getHashtagList(_ request: GetHistoryRequest,
                        completion: @escaping CompletionType<[Message]>,
                        cacheResponse: CacheResponseType<[Message]>? = nil,
                        uniqueIdResult: UniqueIdResultType? = nil)
    {
        getHistory(request, completion: completion, cacheResponse: cacheResponse, textMessageNotSentRequests: nil, editMessageNotSentRequests: nil, forwardMessageNotSentRequests: nil, fileMessageNotSentRequests: nil, uniqueIdResult: uniqueIdResult)
    }

    internal func saveMessagesToCache(_ messages: [Message]?, _: CompletionType<[Message]>?) {
        messages?.forEach { message in
            cache?.write(cacheType: .message(message))
            cache?.write(cacheType: .deleteQueue(message.uniqueId ?? ""))
        }
        cache?.save()
    }
}

// Response
extension Chat {
    func onGetHistroy(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Message]> = asyncMessage.toChatResponse(context: persistentManager.context)
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
