//
// ChangeThreadTypeResposneHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class ChangeThreadTypeResposneHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance
        if chat.config?.enableCache == true, let threadId = chatMessage.subjectId {
            chat.delegate?.chatEvent(event: .thread(.threadRemovedFrom(threadId: threadId)))
            CacheFactory.write(cacheType: .deleteThreads([threadId]))
        }
        if let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId), let data = chatMessage.content?.data(using: .utf8) {
            let thread = try? JSONDecoder().decode(Conversation.self, from: data)
            callback(.init(uniqueId: chatMessage.uniqueId, result: thread))
        }
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .changeThreadType)
    }
}
