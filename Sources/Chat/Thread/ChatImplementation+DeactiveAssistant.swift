//
// ChatImplementation+DeactiveAssistant.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension ChatImplementation {
    /// Deactivate assistants.
    /// - Parameters:
    ///   - request: A request that contains a list of activated assistants.
    ///   - completion: The result of deactivated assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func deactiveAssistant(_ request: DeactiveAssistantRequest, completion: @escaping CompletionType<[Assistant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .deacticveAssistant, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension ChatImplementation {
    func onDeactiveAssistants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .assistant(.deactiveAssistants(response)))
        cache?.assistant?.delete(response.result ?? [])
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
