//
// IsThreadNamePublicRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class IsThreadNamePublicRequestHandler {
    class func handle(_ req: IsThreadNamePublicRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<String>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            let threadNameResponse = response.result as? PublicThreadNameAvailableResponse
            completion(threadNameResponse?.name, response.uniqueId, response.error)
        }
    }
}
