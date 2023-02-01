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

        let response = cache?.message?.fetch(request)
        let pagination = Pagination(hasNext: response?.totalCount ?? 0 >= request.count, count: request.count, offset: request.offset)
        cacheResponse?(ChatResponse(uniqueId: request.uniqueId, result: response?.messages.map { $0.codable() }, error: nil, contentCount: response?.totalCount, pagination: pagination))

        let resText = cache?.textQueue?.unsendForThread(request.threadId, request.count, request.offset)
        textMessageNotSentRequests?(ChatResponse(uniqueId: request.uniqueId, result: resText?.objects.map(\.codable.request), error: nil))

        let resEdit = cache?.editQueue?.unsedForThread(request.threadId, request.count, request.offset)
        editMessageNotSentRequests?(ChatResponse(uniqueId: request.uniqueId, result: resEdit?.objects.map(\.codable.request), error: nil))

        let resForward = cache?.forwardQueue?.unsedForThread(request.threadId, request.count, request.offset)
        forwardMessageNotSentRequests?(ChatResponse(uniqueId: request.uniqueId, result: resForward?.objects.map(\.codable.request), error: nil))

        let resFile = cache?.fileQueue?.unsedForThread(request.threadId, request.count, request.offset)
        fileMessageNotSentRequests?(ChatResponse(uniqueId: request.uniqueId, result: resFile?.objects.map(\.codable.request), error: nil))
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
        cache?.message?.insert(models: messages ?? [])
        let uniqueIds = messages?.compactMap(\.uniqueId) ?? []
        deleteQueues(uniqueIds: uniqueIds)
    }
}

// Response
extension Chat {
    func onGetHistroy(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Message]> = asyncMessage.toChatResponse()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
