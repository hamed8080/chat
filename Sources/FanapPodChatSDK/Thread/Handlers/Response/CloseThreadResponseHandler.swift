//
// CloseThreadResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class CloseThreadResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let threadId = chatMessage.subjectId else { return }
        chat.delegate?.chatEvent(event: .thread(.threadClosed(threadId: threadId)))
        CacheFactory.write(cacheType: .threads([.init(id: threadId)]))
        CacheFactory.save()

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }

        callback(.init(uniqueId: chatMessage.uniqueId, result: threadId))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .closeThread)
    }
}
