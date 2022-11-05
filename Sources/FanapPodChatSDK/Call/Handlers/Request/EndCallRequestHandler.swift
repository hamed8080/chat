//
// EndCallRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class EndCallRequestHandler {
    class func handle(_ req: EndCallRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Int>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: nil,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.callId,
                                messageType: .endCallRequest,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? Int, response.uniqueId, response.error)
        }
    }
}
