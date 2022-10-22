//
// SendStatusPingRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class SendStatusPingRequestHandler {
    class func handle(_ req: SendStatusPingRequest, _ chat: Chat) {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType: .statusPing)
    }
}
