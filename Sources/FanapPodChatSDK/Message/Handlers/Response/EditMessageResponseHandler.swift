//
// EditMessageResponseHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

class EditMessageResponseHandler: ResponseHandler {
    static func handle(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let chat = Chat.sharedInstance

        let message = Message(chatMessage: chatMessage)

        chat.delegate?.chatEvent(event: .message(.messageEdit(message)))
        chat.delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))

        CacheFactory.write(cacheType: .deleteEditMessageQueue(message))
        CacheFactory.write(cacheType: .message(message))
        PSM.shared.save()

        guard let callback = Chat.sharedInstance.callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(.init(uniqueId: chatMessage.uniqueId, result: message))
        chat.callbacksManager.removeSentCallback(uniqueId: chatMessage.uniqueId)
    }
}
