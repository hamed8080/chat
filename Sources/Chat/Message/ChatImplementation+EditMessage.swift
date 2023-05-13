//
// ChatImplementation+EditMessage.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension ChatImplementation {
    /// Edit a message.
    /// - Parameters:
    ///   - request: The request that contains threadId and messageId and new text for the message you want to edit.
    ///   - completion: The result of edited message.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func editMessage(_ request: EditMessageRequest, completion: CompletionType<Message>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .editMessage, uniqueIdResult: uniqueIdResult, completion: completion)
        cache?.editQueue.insert(request.queueOfTextMessages)
    }
}

// Response
extension ChatImplementation {
    func onEditMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Message> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .message(.messageEdit(response)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        if let message = response.result {
            cache?.deleteQueues(uniqueIds: [response.uniqueId ?? ""])
            cache?.message.insert(models: [message])
        }
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
