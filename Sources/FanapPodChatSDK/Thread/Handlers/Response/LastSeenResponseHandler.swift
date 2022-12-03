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
        let lastMessageSeenUpdated = try? JSONDecoder().decode(LastSeenMessageResponse.self, from: chatMessage.content?.data(using: .utf8) ?? Data())
        chat.delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        if let unreadCount = lastMessageSeenUpdated?.unreadCount, let threadId = lastMessageSeenUpdated?.id {
            chat.delegate?.chatEvent(event: .thread(.threadUnreadCountUpdated(threadId: threadId, count: unreadCount)))
            CacheFactory.write(cacheType: .setThreadUnreadCount(threadId, unreadCount))
        }
    }
}

struct LastSeenMessageResponse: Decodable {
    let unreadCount: Int?
    let id: Int?
    var uniqueId: String?

    enum CodingKeys: CodingKey {
        case unreadCount
        case id
    }

    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.unreadCount = try container?.decodeIfPresent(Int.self, forKey: .unreadCount)
        self.id = try container?.decodeIfPresent(Int.self, forKey: .id)
    }
}
