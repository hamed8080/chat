//
// Chat+Assistants.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Get list of assistants for user.
    /// - Parameters:
    ///   - request: A request with a contact type and offset, count.
    ///   - completion: The list of assistants.
    ///   - cacheResponse: The cache response of list of assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getAssistats(_ request: AssistantsRequest, completion: @escaping CompletionType<[Assistant]>, cacheResponse: CompletionType<[Assistant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Assistant]>) in
            let pagination = PaginationWithContentCount(count: request.count, offset: request.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }

        cache?.get(cacheType: .getAssistants(request.count, request.offset)) { (response: ChatResponse<[Assistant]>) in
            let pagination = PaginationWithContentCount(count: request.count, offset: request.offset, totalCount: CMAssistant.crud.getTotalCount())
            cacheResponse?(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }
    }
}

// Response
extension Chat {
    func onAssistants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .assistant(.assistants(response)))
        cache?.write(cacheType: .insertOrUpdateAssistants(response.result ?? []))
        cache?.save()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
