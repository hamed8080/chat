//
// PinThreadResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class PinThreadResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let threadId = try? JSONDecoder().decode(Int.self, from: data) else { return }
        if chatMessage.type == .pinThread {
            chat.delegate?.chatEvent(event: .thread(.threadPin(threadId: threadId)))
        } else if chatMessage.type == .unpinThread {
            chat.delegate?.chatEvent(event: .thread(.threadUnpin(threadId: threadId)))
        }

        let resposne = PinThreadResponse(threadId: threadId)
        CacheFactory.write(cacheType: .pinUnpinThread(threadId))
        CacheFactory.save()

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: resposne))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .pinThread)
    }
}
