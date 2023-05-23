//
// ChatImplementation+RemoveParticipants.swift
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
    /// Remove participants from a thread.
    /// - Parameters:
    ///   - request: List of participants id and threadId.
    ///   - completion: Result of deleted participants.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func removeParticipants(_ request: RemoveParticipantsRequest, completion: @escaping CompletionType<[Participant]>, uniqueIdResult: UniqueIdResultType? = nil) {
        prepareToSendAsync(req: request, type: .removeParticipant, uniqueIdResult: uniqueIdResult, completion: completion)
    }
}

// Response
extension ChatImplementation {
    func onRemoveParticipants(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Participant]> = asyncMessage.toChatResponse()
        cache?.participant?.delete(response.result ?? [])
        delegate?.chatEvent(event: .thread(.threadRemoveParticipants(response)))
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
