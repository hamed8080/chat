//
// AddBotCommandRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class AddBotCommandRequestHandler {
    class func handle(_ req: AddBotCommandRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<BotInfo>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType: .defineBotCommand,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? BotInfo, response.uniqueId, response.error)
        }
    }
}
