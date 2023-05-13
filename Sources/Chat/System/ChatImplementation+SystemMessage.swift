//
// ChatImplementation+SystemMessage.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import Foundation

// Event
extension ChatImplementation {
    func onSystemMessageEvent(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<SystemEventMessageModel> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .system(.systemMessage(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
