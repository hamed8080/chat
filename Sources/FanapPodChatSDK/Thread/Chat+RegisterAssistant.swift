//
// Chat+RegisterAssistant.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestRegisterAssistant(_ req: RegisterAssistantRequest, _ completion: @escaping CompletionType<[Assistant]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onRegisterAssistants(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let assistants = try? JSONDecoder().decode([Assistant].self, from: data) else { return }
        delegate?.chatEvent(event: .assistant(.registerAssistant(assistants)))
        cache.write(cacheType: .insertOrUpdateAssistants(assistants))
        cache.save()
        guard let callback: CompletionType<[Assistant]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: assistants))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .registerAssistant)
    }
}
