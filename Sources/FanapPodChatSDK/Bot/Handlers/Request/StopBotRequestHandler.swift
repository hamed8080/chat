//
// StopBotRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class StopBotRequestHandler {
    class func handle(_ req: StartStopBotRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<String>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        req.chatMessageType = .stopBot
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? String, response.uniqueId, response.error)
        }
    }
}
