//
// ForwardMessagesRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class ForwardMessagesRequestHandler {
    class func handle(_ req: ForwardMessageRequest,
                      _ chat: Chat,
                      _ onSent: OnSentType = nil,
                      _ onSeen: OnSeenType = nil,
                      _ onDeliver: OnDeliveryType = nil,
                      _ uniqueIdsResult: UniqueIdsResultType = nil)
    {
        uniqueIdsResult?(req.uniqueIds) // do not remove this line it use batch uniqueIds

        chat.prepareToSendAsync(req: "\(req.messageIds)",
                                clientSpecificUniqueId: "\(req.uniqueIds)",
                                subjectId: req.threadId,
                                plainText: true,
                                messageType: .forwardMessage,
                                uniqueIdResult: nil,
                                completion: nil,
                                onSent: onSent,
                                onDelivered: onDeliver,
                                onSeen: onSeen)

        req.uniqueIds.forEach { uniqueId in
            chat.callbacksManager.addCallback(uniqueId: uniqueId, requesType: .forwardMessage, callback: nil, onSent: onSent, onDelivered: onDeliver, onSeen: onSeen)
        }
        CacheFactory.write(cacheType: .forwardMessageQueue(req))
        PSM.shared.save()
    }
}
