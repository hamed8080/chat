//
// Chat+AssistantsHistory.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestAssitantHistory(_ completion: @escaping CompletionType<[AssistantAction]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        let req = BareChatSendableRequest()
        req.chatMessageType = .getAssistantHistory
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onAssistantHistory(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let assistantsActions = try? JSONDecoder().decode([AssistantAction].self, from: data) else { return }
        delegate?.chatEvent(event: .assistant(.assistantActions(assistantsActions)))
        guard let callback: CompletionType<[AssistantAction]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: assistantsActions))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .getAssistantHistory)
    }
}
