//
// SeenMessageResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class SeenMessageResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        if let data = chatMessage.content?.data(using: .utf8), let seenResponse = try? JSONDecoder().decode(MessageResponse.self, from: data) {
            seenResponse.messageState = .seen
            chat.delegate?.chatEvent(event: .message(.messageSeen(seenResponse)))
            CacheFactory.write(cacheType: .messageSeenByUser(seenResponse))
            CacheFactory.save()
            guard let callback = Chat.sharedInstance.callbacksManager.getSeenCallback(chatMessage.uniqueId) else { return }
            callback(seenResponse, chatMessage.uniqueId, nil)
            chat.callbacksManager.removeSeenCallback(uniqueId: chatMessage.uniqueId)
        }
    }
}
