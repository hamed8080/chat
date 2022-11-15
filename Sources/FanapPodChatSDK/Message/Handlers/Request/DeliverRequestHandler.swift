//
// DeliverRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class DeliverRequestHandler {
    class func handle(_ req: MessageDeliverRequest, _ chat: Chat, _ uniqueIdResult: UniqueIdResultType? = nil) {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult)
    }
}
