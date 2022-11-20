//
// ThreadsMentionResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class ThreadsMentionResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let mentions = try? JSONDecoder().decode([Message].self, from: data) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: mentions, contentCount: chatMessage.contentCount ?? 0))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .getHistory)
    }
}
