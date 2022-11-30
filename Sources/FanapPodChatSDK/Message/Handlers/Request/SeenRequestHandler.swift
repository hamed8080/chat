//
// SeenRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class SeenRequestHandler {
    class func handle(_ req: MessageSeenRequest, _ chat: Chat, _ uniqueIdResult: UniqueIdResultType? = nil) {
        chat.prepareToSendAsync(req: req, uniqueIdResult: uniqueIdResult)
        CacheFactory.write(cacheType: .lastThreadMessageSeen(req.threadId, req.messageId))
        CacheFactory.save()        
    }
}
