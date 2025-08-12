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
        let assistantCache = chat.cache?.assistant
        Task { @MainActor in
            if let (assistants, _) = assistantCache?.fetch(request.count, request.offset) {
                emitEvent(event: assistants.toCachedAssistantsEvent(request, typeCode))
            }
        }
    }
    
    func onAssistants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse(asyncManager: chat.asyncManager)
        let copies = response.result?.compactMap{ $0 } ?? []
        emitEvent(.assistant(.assistants(response)))
        chat.cache?.assistant?.insert(models: copies)
    }
    
    func history(_ request: AssistantsHistoryRequest) {
        chat.prepareToSendAsync(req: request, type: .getAssistantHistory)
    }
    
    func onAssistantHistory(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[AssistantAction]> = asyncMessage.toChatResponse()
        emitEvent(.assistant(.actions(response)))
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
        emitEvent(.assistant(block ? .block(response) : .unblock(response)))
        Task {
            await chat.cache?.assistant?.block(block: asyncMessage.chatMessage?.type == .blockAssistant, assistants: copies)
        }
    }
    
    func blockedList(_ request: BlockedAssistantsRequest) {
        chat.prepareToSendAsync(req: request, type: .blockedAssistnts)
        let typeCode = request.toTypeCode(chat)
        let assistantCache = chat.cache?.assistant
        Task { @MainActor in
            if let (assistants, _) = assistantCache?.getBlocked(request.count, request.offset), let assistants = assistants {
                emitEvent(event: assistants.toCachedBlockedAssistantsEvent(request, typeCode))
            }
        }
    }
    
    func onGetBlockedAssistants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse(asyncManager: chat.asyncManager)
        let copies = response.result?.compactMap{$0} ?? []
        chat.cache?.assistant?.insert(models: copies)
        emitEvent(.assistant(.blockedList(response)))
    }
    
    func deactive(_ request: DeactiveAssistantRequest) {
        chat.prepareToSendAsync(req: request, type: .deacticveAssistant)
    }
    
    func onDeactiveAssistants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse()
        let copies = response.result?.compactMap{$0} ?? []
        emitEvent(.assistant(.deactive(response)))
        Task {
            await chat.cache?.assistant?.delete(copies)
        }
    }
    
    func register(_ request: RegisterAssistantsRequest) {
        chat.prepareToSendAsync(req: request, type: .registerAssistant)
    }
    
    func onRegisterAssistants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Assistant]> = asyncMessage.toChatResponse()
        let copies = response.result?.compactMap{$0} ?? []
        emitEvent(.assistant(.register(response)))
        chat.cache?.assistant?.insert(models: copies)
    }
    
    private nonisolated func emitEvent(event: ChatEventType) {
        Task { @ChatGlobalActor [weak self] in
            self?.emitEvent(event)
        }
    }
    
    private func emitEvent(_ event: ChatEventType) {
        chat.delegate?.chatEvent(event: event)
    }
}
