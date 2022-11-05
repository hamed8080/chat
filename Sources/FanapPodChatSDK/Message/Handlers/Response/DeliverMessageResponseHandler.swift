//
// DeliverMessageResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class DeliverMessageResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance
        let message = Message(chatMessage: chatMessage)

        chat.delegate?.chatEvent(event: .message(.messageDelivery(message)))

        CacheFactory.write(cacheType: .message(message))
        CacheFactory.save()

        if let callback = Chat.sharedInstance.callbacksManager.getDeliverCallback(chatMessage.uniqueId) {
            let messageResponse = DeliverMessageResponse(isDeliver: true, messageId: message.id, threadId: chatMessage.subjectId, message: message, participantId: chatMessage.participantId)
            callback?(messageResponse, chatMessage.uniqueId, nil)
            chat.callbacksManager.removeDeliverCallback(uniqueId: chatMessage.uniqueId)
        }
    }
}
