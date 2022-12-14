//
// Chat+Logout.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

// Request
extension Chat {
    func requestLogout() {
        let req = BareChatSendableRequest(uniqueId: UUID().uuidString)
        req.chatMessageType = .logout
        prepareToSendAsync(req: req)
        cache.write(cacheType: .deleteAllCacheData)
        cache.save()
        dispose()
    }
}
