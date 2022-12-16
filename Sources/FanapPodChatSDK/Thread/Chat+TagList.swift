//
// Chat+TagList.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestTags(_ uniqueId: String? = nil, _ completion: @escaping CompletionType<[Tag]>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        let req = BareChatSendableRequest(uniqueId: uniqueId)
        req.chatMessageType = .tagList
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onTags(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let tags = try? JSONDecoder().decode([Tag].self, from: data) else { return }
        cache.write(cacheType: .tags(tags))
        cache.save()
        guard let callback: CompletionType<[Tag]> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: tags))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .tagList)
    }
}
