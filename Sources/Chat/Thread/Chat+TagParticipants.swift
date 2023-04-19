//
// Chat+TagParticipants.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
extension Chat {
    /// Get the list of tag participants.
    /// - Parameters:
    ///   - request: The tag id.
    ///   - completion: List of tag participants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getTagParticipants(_ request: GetTagParticipantsRequest, completion: @escaping CompletionType<[TagParticipant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension Chat {
    func onTagParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[TagParticipant]> = asyncMessage.toChatResponse()
        cache?.tagParticipant.insert(models: response.result?.compactMap { $0 } ?? [])
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
