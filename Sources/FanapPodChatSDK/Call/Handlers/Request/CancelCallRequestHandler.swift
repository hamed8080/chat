//
// CancelCallRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class CancelCallRequestHandler {
    class func handle(_ req: CancelCallRequest,
                      _ chat: Chat,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.callState = .canceled
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult)
    }
}
