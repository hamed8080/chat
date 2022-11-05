//
// EditMessageRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class EditMessageRequestHandler {
    class func handle(_ req: EditMessageRequest,
                      _ chat: Chat,
                      _ completion: CompletionType<Message>? = nil,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req.textMessage,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.messageId,
                                plainText: true,
                                messageType: .editMessage,
                                messageMessageType: req.messageType,
                                metadata: req.metadata,
                                repliedTo: req.repliedTo,
                                uniqueIdResult: uniqueIdResult) { response in
            completion?(response.result as? Message, response.uniqueId, response.error)
        }
        CacheFactory.write(cacheType: .editMessageQueue(req))
        PSM.shared.save()
    }
}
