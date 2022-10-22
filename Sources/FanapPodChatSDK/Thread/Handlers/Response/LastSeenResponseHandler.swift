//
// LastSeenResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class LastSeenResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let conversations = try? JSONDecoder().decode(Conversation.self, from: data) else { return }
        let unreadCount = try? JSONDecoder().decode(UnreadCount.self, from: chatMessage.content?.data(using: .utf8) ?? Data())
        chat.delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        if let unreadCount = unreadCount, let threadId = chatMessage.subjectId {
            chat.delegate?.chatEvent(event: .thread(.threadUnreadCountUpdated(threadId: threadId, count: unreadCount.unreadCount)))
            CacheFactory.write(cacheType: .setThreadUnreadCount(threadId, unreadCount.unreadCount))
        }
        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: conversations))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .lastSeenUpdated)
    }
}

struct UnreadCount: Decodable {
    let unreadCount: Int
}
