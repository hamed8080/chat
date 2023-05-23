//
// ChatImplementation+Assistants.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension ChatImplementation {
    /// Get list of assistants for user.
    /// - Parameters:
    ///   - request: A request with a contact type and offset, count.
    ///   - completion: The list of assistants.
    ///   - cacheResponse: The cache response of list of assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getAssistats(_ request: AssistantsRequest, completion: @escaping CompletionType<[Assistant]>, cacheResponse: CompletionType<[Assistant]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .getAssistants, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<[Assistant]>) in
            let pagination = PaginationWithContentCount(hasNext: response.result?.count ?? 0 >= request.count, count: request.count, offset: request.offset, totalCount: response.contentCount)
            completion(ChatResponse(uniqueId: response.uniqueId, result: response.result, error: response.error, pagination: pagination))
        }

        cache?.assistant?.fetch(request.offset, request.count) { [weak self] assistants, totalCount in
            let assistants = assistants.map(\.codable)
            self?.responseQueue.async {
                let pagination = PaginationWithContentCount(hasNext: assistants.count >= request.count, count: request.count, offset: request.offset, totalCount: totalCount)
                cacheResponse?(ChatResponse(uniqueId: request.uniqueId, result: assistants, error: nil, pagination: pagination))
            }
        }
    }
}

// Response
extension ChatImplementation {
    func onAssistants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .assistant(.assistants(response)))
        cache?.assistant?.insert(models: response.result ?? [])
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
