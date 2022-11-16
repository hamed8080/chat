//
// MessageResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class MessageResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let data = chatMessage.content?.data(using: .utf8), let message = try? JSONDecoder().decode(Message.self, from: data) else { return }
        chat.delegate?.chatEvent(event: .message(.messageNew(message)))

        chat.delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        let unreadCount = try? JSONDecoder().decode(UnreadCount.self, from: chatMessage.content?.data(using: .utf8) ?? Data())
        chat.delegate?.chatEvent(event: .thread(.threadUnreadCountUpdated(threadId: chatMessage.subjectId ?? 0, count: unreadCount?.unreadCount ?? 0)))

        if chat.config?.enableCache == true {
            if message.threadId == nil {
                message.threadId = chatMessage.subjectId ?? message.conversation?.id
            }
            CacheFactory.write(cacheType: .message(message))

            if let messageId = message.id, message.participant?.id != nil { // check message has participant id and not a system broadcast message
                chat.deliver(.init(messageId: messageId))
            }
            if let threadId = message.threadId {
                CacheFactory.write(cacheType: .setThreadUnreadCount(threadId, message.conversation?.unreadCount ?? 0))
            }
        }
        CacheFactory.save()
    }
}
