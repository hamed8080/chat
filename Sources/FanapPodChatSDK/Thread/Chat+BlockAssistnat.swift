//
// Chat+BlockAssistnat.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestBlockAssistant(_ req: BlockUnblockAssistantRequest, _ completion: @escaping CompletionType<[Assistant]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    func requestUnBlockAssistant(_ req: BlockUnblockAssistantRequest, _ completion: @escaping CompletionType<[Assistant]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .unblockAssistant
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onBlockUnBlockAssistant(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let assistants = try? JSONDecoder().decode([Assistant].self, from: data) else { return }
        if asyncMessage.chatMessage?.type == .blockAssistant {
            delegate?.chatEvent(event: .assistant(.blockAssistant(assistants)))
        } else if asyncMessage.chatMessage?.type == .unblockAssistant {
            delegate?.chatEvent(event: .assistant(.unblockAssistant(assistants)))
        }
        cache.write(cacheType: .insertOrUpdateAssistants(assistants))
        cache.save()
        guard let callback: CompletionType<[Assistant]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: assistants))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .blockAssistant)
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .unblockAssistant)
    }
}
