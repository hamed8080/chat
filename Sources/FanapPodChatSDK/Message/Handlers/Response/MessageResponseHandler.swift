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
        let unreadCount = message.conversation?.unreadCount ?? 0
        chat.delegate?.chatEvent(event: .thread(.threadUnreadCountUpdated(threadId: chatMessage.subjectId ?? 0, count: unreadCount)))

        if message.threadId == nil {
            message.threadId = chatMessage.subjectId ?? message.conversation?.id
        }
        CacheFactory.write(cacheType: .message(message))

        // Check that we are not the sender of the message and message come from another person.
        if let messageId = message.id, message.participant?.id != Chat.sharedInstance.userInfo?.id {
            chat.deliver(.init(messageId: messageId))
        }
        if let threadId = message.threadId {
            CacheFactory.write(cacheType: .setThreadUnreadCount(threadId, message.conversation?.unreadCount ?? 0))
        }
        CacheFactory.save()
    }
}
