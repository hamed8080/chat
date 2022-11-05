//
// UserRemovedFromThreadServerAction.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class UserRemovedFromThreadServerAction: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance
        guard let threadId = chatMessage.subjectId else { return }
        chat.delegate?.chatEvent(event: .thread(.threadRemovedFrom(threadId: threadId)))

        if chat.config?.enableCache == true {
            CacheFactory.write(cacheType: .deleteThreads([threadId]))
        }
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .removedFromThread)
    }
}
