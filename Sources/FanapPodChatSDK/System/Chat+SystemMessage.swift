//
// Chat+SystemMessage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Event
extension Chat {
    func onSystemMessageEvent(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<SystemEventMessageModel> = asyncMessage.toChatResponse(context: persistentManager.context)
        delegate?.chatEvent(event: .system(.systemMessage(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
