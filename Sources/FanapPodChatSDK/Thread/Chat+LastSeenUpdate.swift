//
// Chat+LastSeenUpdate.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Event
extension Chat {
    func onLastSeenUpdate(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<LastSeenMessageResponse> = asyncMessage.toChatResponse(context: persistentManager.context)
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        if let unreadCount = response.result?.unreadCount, let threadId = response.result?.id {
            let unreadCountInstance = UnreadCount(unreadCount: unreadCount, threadId: threadId)
            delegate?.chatEvent(event: .thread(.threadUnreadCountUpdated(.init(result: unreadCountInstance))))
            cache?.write(cacheType: .setThreadUnreadCount(threadId, unreadCount))
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
        unreadCount = try container?.decodeIfPresent(Int.self, forKey: .unreadCount)
        id = try container?.decodeIfPresent(Int.self, forKey: .id)
    }
}
