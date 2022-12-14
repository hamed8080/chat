//
// Chat+ContactsLastSeen.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Event
extension Chat {
    func onUsersLastSeen(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let users = try? JSONDecoder().decode([UserLastSeenDuration].self, from: data) else { return }
        delegate?.chatEvent(event: .contact(.contactsLastSeen(users)))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .contactsLastSeen)
    }
}
