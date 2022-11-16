//
// UnMuteThreadRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class UnMuteThreadRequestHandler {
    class func handle(_ req: GeneralSubjectIdRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Int>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        req.chatMessageType = .unmuteThread
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            let unmuteResponse = response.result as? UnMuteThreadResponse
            completion(unmuteResponse?.threadId, response.uniqueId, response.error)
        }
    }
}
