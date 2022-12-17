//
// Chat+Logout.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

// Request
public extension Chat {
    /// Tell the server user has logged out.
    func logOut() {
        let req = BareChatSendableRequest(uniqueId: UUID().uuidString)
        req.chatMessageType = .logout
        prepareToSendAsync(req: req)
        cache.write(cacheType: .deleteAllCacheData)
        cache.save()
        dispose()
    }
}
