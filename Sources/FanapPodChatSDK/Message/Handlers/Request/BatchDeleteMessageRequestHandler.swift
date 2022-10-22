//
// BatchDeleteMessageRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class BatchDeleteMessageRequestHandler {
    class func handle(_ req: BatchDeleteMessageRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Message>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        req.uniqueIds.forEach { uniqueId in
            chat.callbacksManager.addCallback(uniqueId: uniqueId, requesType: .deleteMessage, callback: { response in
                completion(response.result as? Message, response.uniqueId, response.error)
            })
        }
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                messageType: .deleteMessage,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? Message, response.uniqueId, response.error)
        }
    }
}
