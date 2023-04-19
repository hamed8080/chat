//
// Chat+LastSeenUpdate.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Event
extension Chat {
    func onLastSeenUpdate(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<LastSeenMessageResponse> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        if let threadId = response.result?.id, let unreadCount = response.result?.unreadCount {
            cache?.conversation.updateThreadsUnreadCount(["\(threadId)": unreadCount])
            let unreadCountModel = UnreadCount(unreadCount: unreadCount, threadId: threadId)
            delegate?.chatEvent(event: .thread(.threadUnreadCountUpdated(.init(uniqueId: response.uniqueId, result: unreadCountModel, time: response.time))))
        }
    }
}
