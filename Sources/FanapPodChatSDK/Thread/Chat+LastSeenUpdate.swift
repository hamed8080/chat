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
        let response: ChatResponse<LastSeenMessageResponse> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId), typeCode: response.typeCode))))
        if let threadId = response.result?.id, let unreadCount = response.result?.unreadCount {
            let unreadCountModel = UnreadCount(unreadCount: unreadCount, threadId: threadId)
            delegate?.chatEvent(event: .thread(.threadUnreadCountUpdated(.init(uniqueId: response.uniqueId, result: unreadCountModel, time: response.time, typeCode: response.typeCode))))
        }
    }
}
