//
// Chat+Assistants.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestAssistants(_ req: AssistantsRequest,
                           _ completion: @escaping CompletionType<[Assistant]>,
                           _ cacheResponse: CompletionType<[Assistant]>? = nil,
                           _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Assistant]>) in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }

        cache.get(useCache: cacheResponse != nil, cacheType: .getAssistants(req.count, req.offset)) { (response: ChatResponse<[Assistant]>) in
            let pagination = PaginationWithContentCount(count: req.count, offset: req.offset, totalCount: CMAssistant.crud.getTotalCount())
            cacheResponse?(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
    }
}

// Response
extension Chat {
    func onAssistants(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let assistants = try? JSONDecoder().decode([Assistant].self, from: data) else { return }
        delegate?.chatEvent(event: .assistant(.assistants(assistants)))
        cache.write(cacheType: .insertOrUpdateAssistants(assistants))
        cache.save()
        guard let callback: CompletionType<[Assistant]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: assistants))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .getAssistants)
    }
}
