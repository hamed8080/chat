//
//  ReplaceAdminAndLeaveThreadRequestHandler.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 4/10/21.
//

import Foundation
class ReplaceAdminAndLeaveThreadRequestHandler {
    class func handle(_ request:NewSafeLeaveThreadRequest,
                      _ chat :Chat,
                      _ completion:@escaping CompletionType<Conversation>,
                      _ newAdminCompletion:CompletionType<[UserRole]>? = nil,
                      _ uniqueIdResult: UniqueIdResultType = nil) {
        let currentUserRolseReq = CurrentUserRolesRequest(threadId: request.threadId , typeCode: request.typeCode)
        chat.getCurrentUserRoles(currentUserRolseReq) { roles, uniqueId, error in
            let isAdmin = roles?.contains(.THREAD_ADMIN) ?? false || roles?.contains(.ADD_RULE_TO_USER) ?? false
            if isAdmin , let roles = roles{
                let roleRequest = RolesRequest(userRoles: [.init(userId: request.participantId, roles: roles)], threadId: request.threadId)
                chat.setRoles(roleRequest) { usersRoles, uniqueId, error in
                    if let usersRoles = usersRoles{
                        newAdminCompletion?(usersRoles , nil,nil)
                        chat.leaveThread(request, completion: completion, uniqueIdResult: uniqueIdResult)
                    }
                }
            }else{
                chat.delegate?.threadEvents(model: .init(type: .THREAD_LEAVE_SAFTLY_FAILED, threadId: request.threadId))
                completion(nil,nil,ChatError(message: "Current User have no Permission to Change the ThreadAdmin", errorCode: 6666, hasError: true))
            }
        }
    }
}
