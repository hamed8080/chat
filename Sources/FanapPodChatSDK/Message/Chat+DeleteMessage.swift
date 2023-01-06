//
// Chat+DeleteMessage.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Delete a message if it's ``Message/deletable``.
    /// - Parameters:
    ///   - request: The delete request with a messageId.
    ///   - completion: The response of deleted message.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func deleteMessage(_ request: DeleteMessageRequest, completion: @escaping CompletionType<Message>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    /// Delete multiple messages at once.
    /// - Parameters:
    ///   - request: The delete request with list of messagesId.
    ///   - completion: List of deleted messages.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func deleteMultipleMessages(_ request: BatchDeleteMessageRequest, completion: @escaping CompletionType<Message>, uniqueIdResult: UniqueIdResultType? = nil) {
        request.uniqueIds.forEach { uniqueId in
            callbacksManager.addCallback(uniqueId: uniqueId, requesType: .deleteMessage, callback: completion)
        }
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onDeleteMessage(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Message> = asyncMessage.toChatResponse(context: persistentManager.context)
        delegate?.chatEvent(event: .message(.messageDelete(response)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        cache?.write(cacheType: .deleteMessage(response.subjectId ?? 0, messageId: response.result?.id ?? 0))
        cache?.save()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
