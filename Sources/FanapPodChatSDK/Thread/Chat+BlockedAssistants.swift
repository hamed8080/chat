//
// Chat+BlockedAssistants.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestGetBlockedAssistants(_ req: BlockedAssistantsRequest,
                                     _ completion: @escaping CompletionType<[Assistant]>,
                                     _ cacheResponse: CacheResponseType<[Assistant]>? = nil,
                                     _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Assistant]>) in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }

        cache.get(useCache: cacheResponse != nil, cacheType: .getBlockedAssistants(req.count, req.offset)) { (response: ChatResponse<[Assistant]>) in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: CMAssistant.crud.getTotalCount())
            cacheResponse?(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
    }
}

// Response
extension Chat {
    func onGetBlockedAssistants(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let assistants = try? JSONDecoder().decode([Assistant].self, from: data) else { return }
        cache.write(cacheType: .insertOrUpdateAssistants(assistants))
        cache.save()
        guard let callback: CompletionType<[Assistant]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: assistants))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .blockAssistant)
    }
}
