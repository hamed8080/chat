//
// Chat+SpamThread.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension Chat {
    /// Mark a thread as an spam
    ///
    /// A spammed thread can't send a message anymore.
    /// - Parameters:
    ///   - request: Request to spam a thread.
    ///   - completion: Response of request.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func spamPvThread(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<Contact>, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .spamPvThread
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onSpamThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Contact> = asyncMessage.toChatResponse()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
