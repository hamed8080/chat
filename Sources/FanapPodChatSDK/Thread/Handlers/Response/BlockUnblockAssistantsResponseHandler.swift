//
// BlockUnblockAssistantsResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

public class BlockUnblockAssistantsResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let assistants = try? JSONDecoder().decode([Assistant].self, from: data) else { return }
        CacheFactory.write(cacheType: .insertOrUpdateAssistants(assistants))
        CacheFactory.save()

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: assistants))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .blockAssistant)
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .unblockAssistant)
    }
}
