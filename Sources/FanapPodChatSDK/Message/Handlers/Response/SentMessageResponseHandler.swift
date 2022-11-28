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
        if let stringMessageId = chatMessage.content, let messageId = Int(stringMessageId), let threadId = chatMessage.subjectId {
            let sentResponse = SentMessageResponse(isSent: true, threadId: threadId, messageId: messageId, messageTime: UInt(chatMessage.time))
            chat.delegate?.chatEvent(event: .message(.messageSent(sentResponse)))
            CacheFactory.write(cacheType: .messageSentToUser(sentResponse))
            CacheFactory.write(cacheType: .deleteQueue(chatMessage.uniqueId))
            CacheFactory.save()
            guard let callback = Chat.sharedInstance.callbacksManager.getSentCallback(chatMessage.uniqueId) else { return }
            callback(sentResponse, chatMessage.uniqueId, nil)
            chat.callbacksManager.removeSentCallback(uniqueId: chatMessage.uniqueId)
        }
    }
}
