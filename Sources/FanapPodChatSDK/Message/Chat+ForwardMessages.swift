//
// Chat+ForwardMessages.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
extension Chat {
    func requestForwardMessages(_ req: ForwardMessageRequest,
                                _ onSent: OnSentType? = nil,
                                _ onSeen: OnSeenType? = nil,
                                _ onDeliver: OnDeliveryType? = nil,
                                _ uniqueIdsResult: UniqueIdsResultType? = nil)
    {
        uniqueIdsResult?(req.uniqueIds) // do not remove this line it use batch uniqueIds
        prepareToSendAsync(req: req, completion: nil as CompletionType<Voidcodable>?, onSent: onSent, onDelivered: onDeliver, onSeen: onSeen)
        req.typeCode = config.typeCode
        req.uniqueIds.forEach { uniqueId in
            callbacksManager.addCallback(uniqueId: uniqueId, requesType: .forwardMessage, callback: nil as CompletionType<Voidcodable>?, onSent: onSent, onDelivered: onDeliver, onSeen: onSeen)
        }
        cache.write(cacheType: .forwardMessageQueue(req))
        cache.save()
    }
}
