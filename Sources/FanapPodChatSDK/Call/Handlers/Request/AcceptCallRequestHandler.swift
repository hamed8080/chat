//
// AcceptCallRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class AcceptCallRequestHandler {
    class func handle(_ req: AcceptCallRequest,
                      _ chat: Chat,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req.client,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.callId,
                                messageType: .acceptCall,
                                uniqueIdResult: uniqueIdResult)
    }
}
