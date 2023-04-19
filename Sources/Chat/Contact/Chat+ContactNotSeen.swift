//
// Chat+ContactNotSeen.swift
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
    /// Check the last time a user opened the application.
    /// - Parameters:
    ///   - request: The request with userIds.
    ///   - completion: List of last seen users with time attached to each item.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func contactNotSeen(_ request: NotSeenDurationRequest, completion: @escaping CompletionType<[UserLastSeenDuration]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult) { (response: ChatResponse<ContactNotSeenDurationRespoonse>) in
            completion(ChatResponse(uniqueId: request.uniqueId, result: response.result?.notSeenDuration, error: response.error))
        }
    }
}

extension Chat {
    func onContactNotSeen(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[ContactNotSeenDurationRespoonse]> = asyncMessage.toChatResponse()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
