//
// ThreadsMentionRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class ThreadsMentionRequestHandler {
    class func handle(_ req: ThreadsMentionRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<[Message]>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? [Message], response.uniqueId, response.error)
        }
    }
}
