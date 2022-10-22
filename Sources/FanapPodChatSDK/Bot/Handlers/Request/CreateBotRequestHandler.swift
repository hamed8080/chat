//
// CreateBotRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class CreateBotRequestHandler {
    class func handle(_ req: CreateBotRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Bot>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req.botName,
                                clientSpecificUniqueId: req.uniqueId,
                                plainText: true,
                                messageType: .createBot,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? Bot, response.uniqueId, response.error)
        }
    }
}
