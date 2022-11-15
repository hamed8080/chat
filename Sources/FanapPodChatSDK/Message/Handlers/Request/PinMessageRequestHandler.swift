//
// PinMessageRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class PinMessageRequestHandler {
    class func handle(_ req: PinUnpinMessageRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<PinUnpinMessage>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? PinUnpinMessage, response.uniqueId, response.error)
        }
    }
}
