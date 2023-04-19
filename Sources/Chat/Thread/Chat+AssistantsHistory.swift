//
// Chat+AssistantsHistory.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension Chat {
    /// Get a history of assitant actions.
    /// - Parameters:
    ///   - completion: The list of actions of an assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getAssistatsHistory(_ completion: @escaping CompletionType<[AssistantAction]>, uniqueIdResult: UniqueIdResultType? = nil) {
        let req = BareChatSendableRequest()
        req.chatMessageType = .getAssistantHistory
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onAssistantHistory(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[AssistantAction]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .assistant(.assistantActions(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
