//
// SpamThreadRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class SpamThreadRequestHandler {
    class func handle(_ req: SpamThreadRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<BlockedContact>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: nil,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.threadId,
                                messageType: .spamPvThread,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? BlockedContact, response.uniqueId, response.error)
        }
    }
}
