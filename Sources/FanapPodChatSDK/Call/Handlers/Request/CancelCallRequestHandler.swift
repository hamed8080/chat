//
// CancelCallRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class CancelCallRequestHandler {
    class func handle(_ req: CancelCallRequest,
                      _ chat: Chat,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req.call,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.call.id,
                                messageType: .cancelCall,
                                uniqueIdResult: uniqueIdResult)
    }
}