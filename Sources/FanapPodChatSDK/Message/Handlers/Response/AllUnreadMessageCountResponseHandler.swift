//
// AllUnreadMessageCountResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class AllUnreadMessageCountResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let unreadCount = try? JSONDecoder().decode(Int.self, from: data) else { return }

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: unreadCount))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .allUnreadMessageCount)
    }
}
