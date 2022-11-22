//
// SentMessageResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class SentMessageResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        let message = Message(chatMessage: chatMessage)
        chat.delegate?.chatEvent(event: .message(.messageSend(message)))
        CacheFactory.write(cacheType: .deleteQueue(chatMessage.uniqueId))
        CacheFactory.save()
        guard let callback = Chat.sharedInstance.callbacksManager.getSentCallback(chatMessage.uniqueId) else { return }
        let messageResponse = SentMessageResponse(isSent: true, messageId: message.id, threadId: chatMessage.subjectId, message: message, participantId: chatMessage.participantId)
        callback(messageResponse, chatMessage.uniqueId, nil)
        chat.callbacksManager.removeSentCallback(uniqueId: chatMessage.uniqueId)
    }
}
