//
// Chat+ForwardMessages.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
public extension Chat {
    /// Forwrad messages to a thread.
    /// - Parameters:
    ///   - request: The request that contains messageId list and a destination threadId.
    ///   - onSent: Is called when a message sent successfully.
    ///   - onSeen: Is called when a message, have seen by a participant successfully.
    ///   - onDeliver: Is called when a message, have delivered to a participant successfully.
    ///   - uniqueIdsResult: The unique id of request. If you manage the unique id by yourself you should leave this closure blank, otherwise, you must use it if you need to know what response is for what request.
    func forwardMessages(_ request: ForwardMessageRequest, onSent: OnSentType? = nil, onSeen: OnSeenType? = nil, onDeliver: OnDeliveryType? = nil, uniqueIdsResult: UniqueIdsResultType? = nil) {
        uniqueIdsResult?(request.uniqueIds) // do not remove this line it use batch uniqueIds
        prepareToSendAsync(req: request, completion: nil as CompletionType<Voidcodable>?, onSent: onSent, onDelivered: onDeliver, onSeen: onSeen)
        request.typeCode = config.typeCode
        request.uniqueIds.forEach { uniqueId in
            callbacksManager.addCallback(uniqueId: uniqueId, requesType: .forwardMessage, callback: nil as CompletionType<Voidcodable>?, onSent: onSent, onDelivered: onDeliver, onSeen: onSeen)
        }
        cache?.forwardQueue?.insert(request)
    }
}
