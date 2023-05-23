//
// ChatImplementation+BlockAssistnat.swift
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
    /// Block assistants.
    /// - Parameters:
    ///   - request: A list of assistants you want to block them.
    ///   - completion: List of blocked assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func blockAssistants(_ request: BlockUnblockAssistantRequest, completion: @escaping CompletionType<[Assistant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .blockAssistant, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    /// UNBlock assistants.
    /// - Parameters:
    ///   - request: A list of assistants you want to unblock them.
    ///   - completion: List of unblocked assistants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func unblockAssistants(_ request: BlockUnblockAssistantRequest, completion: @escaping CompletionType<[Assistant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .unblockAssistant, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension ChatImplementation {
    func onBlockUnBlockAssistant(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse()
        if asyncMessage.chatMessage?.type == .blockAssistant {
            delegate?.chatEvent(event: .assistant(.blockAssistant(response)))
        } else if asyncMessage.chatMessage?.type == .unblockAssistant {
            delegate?.chatEvent(event: .assistant(.unblockAssistant(response)))
        }
        cache?.assistant?.block(block: asyncMessage.chatMessage?.type == .blockAssistant, assistants: response.result ?? [])
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
