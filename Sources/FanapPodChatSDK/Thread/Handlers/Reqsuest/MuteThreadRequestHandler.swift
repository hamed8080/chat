//
// MuteThreadRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class MuteThreadRequestHandler {
    class func handle(_ req: GeneralThreadRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Int>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        req.chatMessageType = .muteThread
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            let muteThreadResponse = response.result as? MuteThreadResponse
            completion(muteThreadResponse?.threadId, response.uniqueId, response.error)
        }
    }
}
