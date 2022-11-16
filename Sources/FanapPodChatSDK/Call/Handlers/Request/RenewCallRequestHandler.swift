//
// RenewCallRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class RenewCallRequestHandler {
    class func handle(_ req: RenewCallRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<CreateCall>,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? CreateCall, response.uniqueId, response.error)
        }
    }
}
