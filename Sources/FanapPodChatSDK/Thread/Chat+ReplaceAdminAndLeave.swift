//
// Chat+ReplaceAdminAndLeave.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import FanapPodAsyncSDK
import Foundation

// Request
public extension Chat {
    /// Leave a thrad with replaceing admin.
    /// - Parameters:
    ///   - request: The request that contains threadId and participantId of new admin.
    ///   - completion: Result of request.
    ///   - newAdminCompletion: Result of new admin.
    ///   - uniqueIdResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func leaveThreadSaftly(_ request: SafeLeaveThreadRequest, completion: @escaping CompletionType<User>, newAdminCompletion: CompletionType<[UserRole]>? = nil, uniqueIdResult: UniqueIdResultType? = nil) {
        let currentUserRolseReq = GeneralSubjectIdRequest(subjectId: request.threadId)
        getCurrentUserRoles(currentUserRolseReq) { [weak self] (response: ChatResponse<[Roles]>) in
            let isAdmin = response.result?.contains(.threadAdmin) ?? false || response.result?.contains(.addRuleToUser) ?? false
            if isAdmin, let roles = response.result {
                let roleRequest = RolesRequest(userRoles: [.init(userId: request.participantId, roles: roles)], threadId: request.threadId)
                self?.setRoles(roleRequest) { (response: ChatResponse<[UserRole]>) in
                    if let usersRoles = response.result {
                        newAdminCompletion?(ChatResponse(uniqueId: request.uniqueId, result: usersRoles, error: response.error))
                        self?.leaveThread(request, completion: completion, uniqueIdResult: uniqueIdResult)
                    }
                }
            } else {
                let chatError = ChatError(message: "Current User have no Permission to Change the ThreadAdmin", errorCode: 6666, hasError: true)
                let response: ChatResponse<Int> = .init(uniqueId: request.uniqueId, result: request.threadId, error: chatError)
                self?.delegate?.chatEvent(event: .thread(.threadLeaveSaftlyFailed(response)))
                completion(ChatResponse(uniqueId: request.uniqueId, error: chatError))
            }
        }
    }
}

// Response
extension Chat {
    func onUserRemovedFromThread(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<Int> = asyncMessage.toChatResponse()
        delegate?.chatEvent(event: .thread(.threadRemovedFrom(response)))
        cache.write(cacheType: .deleteThreads([response.subjectId ?? 0]))
        callbacksManager.invokeAndRemove(response, asyncMessage.chatMessage?.type)
    }
}