//
// RemoveRoleRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class RemoveRoleRequestHandler {
    class func handle(_ chat: Chat,
                      _ req: RolesRequest,
                      _ completion: @escaping CompletionType<[UserRole]>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        req.chatMessageType = .removeRoleFromUser
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? [UserRole], response.uniqueId, response.error)
        }
    }
}
