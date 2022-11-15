//
// UpdateChatProfileRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class UpdateChatProfileRequestHandler {
    class func handle(_ req: UpdateChatProfile,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Profile>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? Profile, response.uniqueId, response.error)
        }
    }
}
