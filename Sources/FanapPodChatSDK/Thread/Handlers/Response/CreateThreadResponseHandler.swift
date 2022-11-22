//
// CreateThreadResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class CreateThreadResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let newThread = try? JSONDecoder().decode(Conversation.self, from: data) else { return }
        chat.delegate?.chatEvent(event: .thread(.threadNew(newThread)))

        CacheFactory.write(cacheType: .threads([newThread]))
        CacheFactory.save()

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: newThread))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .createThread)
    }
}
