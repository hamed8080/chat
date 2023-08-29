//
// Chat+ThreadContactNameUpdated.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Response
extension Chat {
    /// Update when a contact user updates his name or the contacts updated and the name of the thread accordingly updated.
    func onThreadNameContactUpdated(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Conversation> = asyncMessage.toChatResponse()
        response.result?.id = response.subjectId
        delegate?.chatEvent(event: .thread(.threadInfoUpdated(response)))
    }
}
