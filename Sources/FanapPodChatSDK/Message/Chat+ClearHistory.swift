//
// Chat+ClearHistory.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestClearHistory(_ req: GeneralSubjectIdRequest, _ completion: @escaping CompletionType<Int>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.chatMessageType = .clearHistory
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onClearHistory(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let threadId = try? JSONDecoder().decode(Int.self, from: data) else { return }
        cache.write(cacheType: .clearAllHistory(threadId))
        cache.save()
        guard let callback: CompletionType<Int> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: threadId))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .clearHistory)
    }
}
