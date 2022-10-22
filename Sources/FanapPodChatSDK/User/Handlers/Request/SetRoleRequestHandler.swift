//
// SetRoleRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class SetRoleRequestHandler {
    class func handle(_ chat: Chat,
                      _ request: RolesRequest,
                      _ completion: @escaping CompletionType<[UserRole]>,
                      _ uniqueIdResult: UniqueIdResultType)
    {
        chat.prepareToSendAsync(req: request.userRoles,
                                clientSpecificUniqueId: request.uniqueId,
                                subjectId: request.threadId,
                                messageType: .setRuleToUser,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? [UserRole], response.uniqueId, response.error)
        }
    }
}
