//
// CallReceivedRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class CallReceivedRequestHandler {
    class func handle(_ req: CallReceivedRequest,
                      _ chat: Chat)
    {
        chat.prepareToSendAsync(req: req)
    }
}
