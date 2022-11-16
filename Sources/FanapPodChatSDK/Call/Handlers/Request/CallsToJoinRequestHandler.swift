//
// CallsToJoinRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class CallsToJoinRequestHandler {
    class func handle(_ req: GetJoinCallsRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<[Call]>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? [Call], response.uniqueId, response.error)
        }
    }
}
