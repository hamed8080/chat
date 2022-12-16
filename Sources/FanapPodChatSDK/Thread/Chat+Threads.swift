//
// Chat+Threads.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestThreads(_ req: ThreadsRequest,
                        _ completion: @escaping CompletionType<[Conversation]>,
                        _ cacheResponse: CacheResponseType<[Conversation]>? = nil,
                        _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Conversation]>) in
            let threads = response.result
            let pagination = Pagination(hasNext: threads?.count ?? 0 >= req.count, count: req.count, offset: req.offset)
            completion(ChatResponse(uniqueId: response.uniqueId, result: threads, error: response.error, pagination: pagination))
        }

        cache.get(useCache: cacheResponse != nil, cacheType: .getThreads(req)) { (response: ChatResponse<[Conversation]>) in
            let pagination = Pagination(hasNext: response.result?.count ?? 0 >= req.count, count: req.count, offset: req.offset)
            cacheResponse?(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
    }

    func requestAllThreads(_ req: AllThreads,
                           _ completion: @escaping CompletionType<[Conversation]>,
                           _ cacheResponse: CacheResponseType<[Conversation]>? = nil,
                           _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
        cache.get(useCache: cacheResponse != nil, cacheType: .allThreads, completion: cacheResponse)
    }
}

// Response
extension Chat {
    func onThreads(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let conversations = try? JSONDecoder().decode([Conversation].self, from: data) else { return }
        delegate?.chatEvent(event: .thread(.threadsListChange(conversations)))
        cache.write(cacheType: .threads(conversations))
        cache.save()
        guard let callback: CompletionType<[Conversation]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: conversations))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .getThreads)
    }
}
