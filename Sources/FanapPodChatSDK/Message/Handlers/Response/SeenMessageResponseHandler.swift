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

        let message = Message(chatMessage: chatMessage)
        chat.delegate?.chatEvent(event: .message(.messageSeen(message)))
        CacheFactory.write(cacheType: .message(message))
        CacheFactory.save()

        guard let callback = Chat.sharedInstance.callbacksManager.getSeenCallback(chatMessage.uniqueId) else { return }
        let messageResponse = SeenMessageResponse(isSeen: true, messageId: message.id, threadId: chatMessage.subjectId, message: message, participantId: chatMessage.participantId)
        callback?(messageResponse, chatMessage.uniqueId, nil)
        chat.callbacksManager.removeSeenCallback(uniqueId: chatMessage.uniqueId)
    }
}
