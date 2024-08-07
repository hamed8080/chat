//
// AssistantManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

final class AssistantManager: AssistantProtocol {
    let chat: ChatInternalProtocol

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func get(_ request: AssistantsRequest) {
        chat.prepareToSendAsync(req: request, type: .getAssistants)
        let typeCode = request.toTypeCode(chat)
        chat.cache?.assistant?.fetch(request.count, request.offset) { [weak self] assistants, _ in
            let assistants = assistants.map(\.codable)
            let hasNext = assistants.count >= request.count
            let response = ChatResponse(uniqueId: request.uniqueId, result: assistants, hasNext: hasNext, cache: true, typeCode: typeCode)
            self?.chat.delegate?.chatEvent(event: .assistant(.assistants(response)))
        }
    }

    func onAssistants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse(asyncManager: chat.asyncManager)
        let copies = response.result?.compactMap{ $0 } ?? []
        chat.delegate?.chatEvent(event: .assistant(.assistants(response)))
        chat.cache?.assistant?.insert(models: copies)
    }

    func history(_ request: AssistantsHistoryRequest) {
        chat.prepareToSendAsync(req: request, type: .getAssistantHistory)
    }

    func onAssistantHistory(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[AssistantAction]> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .assistant(.actions(response)))
    }

    func block(_ request: BlockUnblockAssistantRequest) {
        chat.prepareToSendAsync(req: request, type: .blockAssistant)
    }

    func unblock(_ request: BlockUnblockAssistantRequest) {
        chat.prepareToSendAsync(req: request, type: .unblockAssistant)
    }

    func onBlockUnBlockAssistant(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse()
        let copies = response.result?.compactMap{$0} ?? []
        let block = asyncMessage.chatMessage?.type == .blockAssistant
        chat.delegate?.chatEvent(event: .assistant(block ? .block(response) : .unblock(response)))
        chat.cache?.assistant?.block(block: asyncMessage.chatMessage?.type == .blockAssistant, assistants: copies)
    }

    func blockedList(_ request: BlockedAssistantsRequest) {
        chat.prepareToSendAsync(req: request, type: .blockedAssistnts)
        let typeCode = request.toTypeCode(chat)
        chat.cache?.assistant?.getBlocked(request.count, request.offset) { [weak self] assistants, _ in
            let assistants = assistants.map(\.codable)
            let hasNext = assistants.count >= request.count
            let response = ChatResponse(uniqueId: request.uniqueId, result: assistants, hasNext: hasNext, cache: true, typeCode: typeCode)
            self?.chat.delegate?.chatEvent(event: .assistant(.blockedList(response)))
        }
    }

    func onGetBlockedAssistants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse(asyncManager: chat.asyncManager)
        let copies = response.result?.compactMap{$0} ?? []
        chat.cache?.assistant?.insert(models: copies)
        chat.delegate?.chatEvent(event: .assistant(.blockedList(response)))
    }

    func deactive(_ request: DeactiveAssistantRequest) {
        chat.prepareToSendAsync(req: request, type: .deacticveAssistant)
    }

    func onDeactiveAssistants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse()
        let copies = response.result?.compactMap{$0} ?? []
        chat.delegate?.chatEvent(event: .assistant(.deactive(response)))
        chat.cache?.assistant?.delete(copies)
    }

    func register(_ request: RegisterAssistantsRequest) {
        chat.prepareToSendAsync(req: request, type: .registerAssistant)
    }

    func onRegisterAssistants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse()
        let copies = response.result?.compactMap{$0} ?? []
        chat.delegate?.chatEvent(event: .assistant(.register(response)))
        chat.cache?.assistant?.insert(models: copies)
    }
}
