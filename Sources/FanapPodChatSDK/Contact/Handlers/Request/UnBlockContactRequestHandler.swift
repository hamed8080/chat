//
// UnBlockContactRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Contacts
import Foundation

class UnBlockContactRequestHandler {
    class func handle(_ req: UnBlockRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<BlockedContact>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? BlockedContact, response.uniqueId, response.error)
        }
    }
}
