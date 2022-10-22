//
// DeleteMessageRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class DeleteMessageRequestHandler {
    class func handle(_ req: DeleteMessageRequest,
                      _ chat: Chat,
                      _ completion: @escaping CompletionType<Message>,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.messageId,
                                messageType: .deleteMessage,
                                uniqueIdResult: uniqueIdResult) { response in
            completion(response.result as? Message, response.uniqueId, response.error)
        }
    }
}
