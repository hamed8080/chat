//
// SystemMessageResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class SystemMessageResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        if let data = chatMessage.content?.data(using: .utf8), let eventMessageModel = try? JSONDecoder().decode(SystemEventMessageModel.self, from: data) {
            chat.delegate?.chatEvent(event: .system(.systemMessage(message: eventMessageModel, time: chatMessage.time, id: chatMessage.subjectId)))
        }
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .systemMessage)
    }
}
