//
// LogoutRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class LogoutRequestHandler {
    class func handle(_ chat: Chat) {
        let req = BareChatSendableRequest(uniqueId: UUID().uuidString)
        req.chatMessageType = .logout
        chat.prepareToSendAsync(req: req)
        CacheFactory.write(cacheType: .deleteAllCacheData)
        CacheFactory.save()
        chat.dispose()
    }
}
