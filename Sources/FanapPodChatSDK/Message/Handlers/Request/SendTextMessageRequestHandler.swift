//
// SendTextMessageRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class SendTextMessageRequestHandler {
    class func handle(_ req: SendTextMessageRequest,
                      _ chat: Chat,
                      _ onSent: OnSentType?,
                      _ onSeen: OnSeenType?,
                      _ onDeliver: OnDeliveryType?,
                      _ uniqueIdResult: UniqueIdResultType? = nil)
    {
        chat.prepareToSendAsync(req: req,
                                uniqueIdResult: uniqueIdResult,
                                onSent: onSent,
                                onDelivered: onDeliver,
                                onSeen: onSeen)
        CacheFactory.write(cacheType: .sendTxetMessageQueue(req))
        CacheFactory.save()
    }
}
