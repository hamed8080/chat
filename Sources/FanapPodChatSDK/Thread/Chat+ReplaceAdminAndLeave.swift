//
// Chat+ReplaceAdminAndLeave.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

// Request
extension Chat {
    func requestChangeAdminAndLeaveThread(_ request: SafeLeaveThreadRequest,
                                          _ completion: @escaping CompletionType<User>,
                                          _ newAdminCompletion: CompletionType<[UserRole]>? = nil,
                                          _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        let currentUserRolseReq = GeneralSubjectIdRequest(subjectId: request.threadId)
        requestCurrentUserRoles(currentUserRolseReq) { [weak self] (response: ChatResponse<[Roles]>) in
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
                self?.delegate?.chatEvent(event: .thread(.threadLeaveSaftlyFailed(threadId: request.threadId)))
                let chatError = ChatError(message: "Current User have no Permission to Change the ThreadAdmin", errorCode: 6666, hasError: true)
                completion(ChatResponse(uniqueId: request.uniqueId, error: chatError))
            }
        }
    }
}

// Response
extension Chat {
    func onUserRemovedFromThread(_ asyncMessage: AsyncMessage) {
        guard let chatMessage = asyncMessage.chatMessage else { return }
        guard let threadId = chatMessage.subjectId else { return }
        delegate?.chatEvent(event: .thread(.threadRemovedFrom(threadId: threadId)))
        if config.enableCache == true {
            cache.write(cacheType: .deleteThreads([threadId]))
        }
        callbacksManager.removeCallback(uniqueId: chatMessage.uniqueId, requestType: .removedFromThread)
    }
}
