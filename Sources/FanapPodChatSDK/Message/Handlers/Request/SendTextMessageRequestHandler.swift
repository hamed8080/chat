//
// SendTextMessageRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class SendTextMessageRequestHandler {
    class func handle(_ req: SendTextMessageRequest,
                      _ chat: Chat,
                      _ onSent: OnSentType,
                      _ onSeen: OnSeenType,
                      _ onDeliver: OnDeliveryType,
                      _ uniqueIdResult: UniqueIdResultType = nil)
    {
        chat.prepareToSendAsync(req: req.textMessage,
                                clientSpecificUniqueId: req.uniqueId,
                                subjectId: req.threadId,
                                plainText: true,
                                messageType: .message,
                                messageMessageType: req.messageType,
                                metadata: req.metadata,
                                systemMetadata: req.systemMetadata,
                                repliedTo: req.repliedTo,
                                uniqueIdResult: uniqueIdResult,
                                completion: nil,
                                onSent: onSent,
                                onDelivered: onDeliver,
                                onSeen: onSeen)
        CacheFactory.write(cacheType: .sendTxetMessageQueue(req))
        PSM.shared.save()
    }
}
