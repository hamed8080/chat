//
// DeleteMessageResposneHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class DeleteMessageResposneHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let deleteMessage = try? JSONDecoder().decode(Message.self, from: data) else { return }

        chat.delegate?.chatEvent(event: .message(.messageDelete(deleteMessage)))
        chat.delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        guard let threadId = chatMessage.subjectId else { return }

        CacheFactory.write(cacheType: .deleteMessage(threadId, messageId: deleteMessage.id ?? 0))
        CacheFactory.save()

        guard let callback = chat.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: deleteMessage))
        chat.callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .deleteMessage)
    }
}
