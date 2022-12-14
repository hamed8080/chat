//
// EditMessageRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestEditMessage(_ req: EditMessageRequest, _ completion: CompletionType<Message>? = nil, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.typeCode = config.typeCode
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
        cache.write(cacheType: .editMessageQueue(req))
        cache.save()
    }
}

// Response
extension Chat {
    func onEditMessage(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        let message = Message(chatMessage: chatMessage)
        delegate?.chatEvent(event: .message(.messageEdit(message)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        cache.write(cacheType: .deleteEditMessageQueue(message))
        cache.write(cacheType: .message(message))
        cache.save()
        guard let callback: CompletionType<Message> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: message))
        callbacksManager.removeSentCallback(uniqueId: chatMessage.uniqueId)
    }
}
