//
// UnPinMessageRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class UnPinMessageRequestHandler {
    class func handle(_ req: PinUnpinMessageRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<PinUnpinMessage>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        req.chatMessageType = .unpinMessage
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? PinUnpinMessage, response.uniqueId, response.error)
        }
    }
}
