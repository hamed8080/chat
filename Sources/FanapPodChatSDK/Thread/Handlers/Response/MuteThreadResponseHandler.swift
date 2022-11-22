//
// MuteThreadResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class MuteThreadResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let threadId = try? JSONDecoder().decode(Int.self, from: data) else { return }
        if chatMessage.type == .muteThread {
            chat.delegate?.chatEvent(event: .thread(.threadMute(threadId: threadId)))
        } else if chatMessage.type == .unmuteThread {
            chat.delegate?.chatEvent(event: .thread(.threadUnmute(threadId: threadId)))
        }

        let resposne = MuteThreadResponse(threadId: threadId)

        CacheFactory.write(cacheType: .muteUnmuteThread(threadId))
        CacheFactory.save()

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: resposne))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .muteThread)
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .unmuteThread)
    }
}
