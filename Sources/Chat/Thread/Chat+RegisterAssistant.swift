//
// Chat+RegisterAssistant.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import Foundation

// Request
public extension Chat {
    /// Register a participant as an assistant.
    /// - Parameters:
    ///   - request: The request that contains list of assistants.
    ///   - completion: A list of assistant that added for the user.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func registerAssistat(_ request: RegisterAssistantRequest, completion: @escaping CompletionType<[Assistant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onRegisterAssistants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .assistant(.registerAssistant(response)))
        cache?.assistant.insert(models: response.result ?? [])
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
