//
// LogoutRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
class LogoutRequestHandler {
    class func handle(_ chat: Chat) {
        chat.prepareToSendAsync(req: nil,
                                clientSpecificUniqueId: UUID().uuidString,
                                messageType: .logout)
        CacheFactory.write(cacheType: .deleteAllCacheData)
        CacheFactory.save()
        chat.dispose()
    }
}
