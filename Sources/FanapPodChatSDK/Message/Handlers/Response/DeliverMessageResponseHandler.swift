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

        // TODO: Must fix when a message send it recieve deliver below code not working and deserialize
        if let data = chatMessage.content?.data(using: .utf8), let deliverResponse = try? JSONDecoder().decode(DeliverMessageResponse.self, from: data) {
            chat.delegate?.chatEvent(event: .message(.messageDelivery(deliverResponse)))
            CacheFactory.write(cacheType: .messageDeliveredToUser(deliverResponse))
            CacheFactory.save()
            guard let callback = Chat.sharedInstance.callbacksManager.getDeliverCallback(chatMessage.uniqueId) else { return }
            callback(deliverResponse, chatMessage.uniqueId, nil)
            chat.callbacksManager.removeDeliverCallback(uniqueId: chatMessage.uniqueId)
        }
    }
}
