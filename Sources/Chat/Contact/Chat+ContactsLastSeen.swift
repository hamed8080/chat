//
// Chat+ContactsLastSeen.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import Foundation

// Event
extension Chat {
    func onUsersLastSeen(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[UserLastSeenDuration]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .contact(.contactsLastSeen(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
