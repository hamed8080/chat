//
// Chat+SetProfile.swift
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
    /// Update current user details.
    /// - Parameters:
    ///   - request: The request that contains bio and metadata.
    ///   - completion: New profile response.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func setProfile(_ request: UpdateChatProfile, completion: @escaping CompletionType<Profile>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onSetProfile(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Profile> = asyncMessage.toChatResponse()
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
