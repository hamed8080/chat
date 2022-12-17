//
// Chat+RemoveRole.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Remove set of roles from a participant.
    /// - Parameters:
    ///   - request: A request that contains a set of roles and a threadId.
    ///   - completion: List of removed roles for a participant.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func removeRoles(_ request: RolesRequest, _ completion: @escaping CompletionType<[UserRole]>, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .removeRoleFromUser
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    /// Remove a participant auditor access roles.
    /// - Parameters:
    ///   - request: A request that contains a threadId and roles of user with userId.
    ///   - completion: List of roles that removed roles for the users.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func removeAuditor(_ request: AuditorRequest, _ completion: @escaping CompletionType<[UserRole]>, uniqueIdResult: UniqueIdResultType? = nil) {
        removeRoles(request, completion, uniqueIdResult: uniqueIdResult)
    }
}

// Response
extension Chat {
    func onRemveUserRoles(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[UserRole]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.threadLastActivityTime(.init(result: .init(time: response.time, threadId: response.subjectId)))))
        delegate?.chatEvent(event: .thread(.threadUserRole(response)))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}