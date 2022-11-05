//
// CloseThreadRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class CloseThreadRequestHandler {
    class func handle(_ req: CloseThreadRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Int>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: nil,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.threadId,
                                messageType: .closeThread,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? Int, response.uniqueId, response.error)
        }
    }
}
