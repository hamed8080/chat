//
// Chat+UserRoles.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension Chat {
    /// Set a set of roles to a participant of a thread.
    /// - Parameters:
    ///   - request: A request that contains a set of roles and a threadId.
    ///   - completion: List of applied roles for a participant.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func setRoles(_ request: RolesRequest, _ completion: @escaping CompletionType<[UserRole]>, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .setRuleToUser
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
    }

    /// Set a participant auditor access roles.
    /// - Parameters:
    ///   - request: A request that contains a threadId and roles of user with userId.
    ///   - completion: List of roles that applied for the users.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func setAuditor(_ request: AuditorRequest, _ completion: @escaping CompletionType<[UserRole]>, uniqueIdResult: UniqueIdResultType? = nil) {
        setRoles(request, completion, uniqueIdResult: uniqueIdResult)
    }

    /// Get the roles of the current user in a thread.
    /// - Parameters:
    ///   - request: A request that contains a threadId.
    ///   - completion: List of the roles of a user.
    ///   - cacheResponse: The cache response of roles.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func getCurrentUserRoles(_ request: GeneralSubjectIdRequest, completion: @escaping CompletionType<[Roles]>, cacheResponse: CacheResponseType<[Roles]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        request.chatMessageType = .getCurrentUserRoles
        prepareToSendAsync(req: request, uniqueIdResult: uniqueIdResult, completion: completion)
        let roles = cache?.userRole.roles(request.subjectId)
        cacheResponse?(ChatResponse(uniqueId: request.uniqueId, result: roles, error: nil))
    }
}

// Response
extension Chat {
    func onUserRoles(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<[Roles]> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .user(.roles(response)))
        let userRole = UserRole(userId: response.subjectId, name: nil, roles: response.result, image: nil)
        cache?.userRole.insert(models: [userRole])
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}
