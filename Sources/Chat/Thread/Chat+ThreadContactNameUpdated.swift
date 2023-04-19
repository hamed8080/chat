//
// Chat+ThreadContactNameUpdated.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatModels
import Foundation

// Response
extension Chat {
    /// Update when a contact user updates his name or the contacts updated and the name of the thread accordingly updated.
    func onThreadNameContactUpdated(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        response.result?.id = response.subjectId
        delegate?.chatEvent(event: .thread(.threadInfoUpdated(response)))
        cache?.conversation.insert(models: [response.result].compactMap { $0 })
    }
}
