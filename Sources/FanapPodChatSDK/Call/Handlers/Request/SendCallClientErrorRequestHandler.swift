//
// SendCallClientErrorRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class SendCallClientErrorRequestHandler {
    class func handle(_ req: CallClientErrorRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<CallError>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.callId,
                                messageType: .callClientErrors,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? CallError, response.uniqueId, response.error)
        }
    }
}
