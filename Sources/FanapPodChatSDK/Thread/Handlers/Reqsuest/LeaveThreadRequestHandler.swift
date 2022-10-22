//
// LeaveThreadRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class LeaveThreadRequestHandler {
    class func handle(_ req: LeaveThreadRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<User>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.threadId,
                                messageType: .leaveThread,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? User, response.uniqueId, response.error)
        }
    }
}
