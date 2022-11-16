//
// PinThreadRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class PinThreadRequestHandler {
    class func handle(_ req: GeneralSubjectIdRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Int>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        req.chatMessageType = .pinThread
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            let pinResponse = response.result as? PinThreadResponse
            completion(pinResponse?.threadId, response.uniqueId, response.error)
        }
    }
}
