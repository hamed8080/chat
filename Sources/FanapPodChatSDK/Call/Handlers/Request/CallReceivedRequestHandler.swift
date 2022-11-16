//
// CallReceivedRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class CallReceivedRequestHandler {
    class func handle(_ req: GeneralSubjectIdRequest,
                      _ chat: Chat)
    {
        req.chatMessageType = .deliveredCallRequest
        chat.prepareToSendAsync(req: req)
    }
}
