//
// Chat+AllUnreadMessageCount.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestUnredMessageCount(_ req: UnreadMessageCountRequest,
                                  _ completion: @escaping CompletionType<Int>,
                                  _ cacheResponse: CacheResponseType<Int>? = nil,
                                  _ uniqueIdResult: ((String) -> Void)? = nil)
    {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
        cache.get(useCache: cacheResponse != nil, cacheType: .allUnreadCount, completion: cacheResponse)
    }
}

// Response
extension Chat {
    func onUnreadMessageCount(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let unreadCount = try? JSONDecoder().decode(Int.self, from: data) else { return }
        guard let callback: CompletionType<Int> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: unreadCount))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .allUnreadMessageCount)
    }
}
