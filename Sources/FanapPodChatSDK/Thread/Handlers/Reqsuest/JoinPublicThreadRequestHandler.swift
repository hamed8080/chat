//
// JoinPublicThreadRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class JoinPublicThreadRequestHandler {
    class func handle(_ req: JoinPublicThreadRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Conversation>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? Conversation, response.uniqueId, response.error)
        }
    }
}
