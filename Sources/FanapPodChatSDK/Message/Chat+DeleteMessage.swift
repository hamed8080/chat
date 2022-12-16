//
// Chat+DeleteMessage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestDeleteMessage(_ req: DeleteMessageRequest, _ completion: @escaping CompletionType<Message>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    func requestBatchDeleteMessage(_ req: BatchDeleteMessageRequest, _ completion: @escaping CompletionType<Message>, _ uniqueIdResult: UniqueIdResultType? = nil) {
        req.uniqueIds.forEach { uniqueId in
            callbacksManager.addCallback(uniqueId: uniqueId, requesType: .deleteMessage, callback: completion)
        }
        prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onDeleteMessage(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let data = chatMessage.content?.data(using: .utf8) else { return }
        guard let deleteMessage = try? JSONDecoder().decode(Message.self, from: data) else { return }
        delegate?.chatEvent(event: .message(.messageDelete(deleteMessage)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(time: chatMessage.time, threadId: chatMessage.subjectId)))
        guard let threadId = chatMessage.subjectId else { return }
        cache.write(cacheType: .deleteMessage(threadId, messageId: deleteMessage.id ?? 0))
        cache.save()
        guard let callback: CompletionType<Message> = callbacksManager.getCallBack(chatMessage.uniqueId) else { return }
        callback(ChatResponse(uniqueId: chatMessage.uniqueId, result: deleteMessage))
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .deleteMessage)
    }
}
