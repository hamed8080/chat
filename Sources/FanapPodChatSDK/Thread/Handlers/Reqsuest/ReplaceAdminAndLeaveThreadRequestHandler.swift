//
// ReplaceAdminAndLeaveThreadRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class ReplaceAdminAndLeaveThreadRequestHandler {
    class func handle(_ request: SafeLeaveThreadRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<User>,
                      _ newAdminCompletion: CompletionType<[UserRole]>? = nil,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        let currentUserRolseReq = GeneralThreadRequest(threadId: request.threadId)
        chat.getCurrentUserRoles(currentUserRolseReq) { roles, _, _ in
            let isAdmin = roles?.contains(.threadAdmin) ?? false || roles?.contains(.addRuleToUser) ?? false
            if isAdmin, let roles = roles {
                let roleRequest = RolesRequest(userRoles: [.init(userId: request.participantId, roles: roles)], threadId: request.threadId)
                chat.setRoles(roleRequest) { usersRoles, _, _ in
                    if let usersRoles = usersRoles {
                        newAdminCompletion?(usersRoles, nil, nil)
                        chat.leaveThread(request, completion: completion, uniqueIdResult: uniqueIdResult)
                    }
                }
            } else {
                chat.delegate?.chatEvent(event: .thread(.threadLeaveSaftlyFailed(threadId: request.threadId)))
                completion(nil, nil, ChatError(message: "Current User have no Permission to Change the ThreadAdmin", errorCode: 6666, hasError: true))
            }
        }
    }
}
