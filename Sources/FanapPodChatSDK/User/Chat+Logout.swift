//
// Chat+Logout.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

// Request
public extension Chat {
    /// Tell the server user has logged out. This method wil **truncate and delete** all data inside the cache.
    func logOut() {
        let req = BareChatSendableRequest(uniqueId: UUID().uuidString)
        req.chatMessageType = .logout
        prepareToSendAsync(req: req)
        truncate()
        if let docFoler = cacheFileManager?.documentPath {
            cacheFileManager?.deleteFolder(url: docFoler)
        }

        if let groupFoler = cacheFileManager?.groupFolder {
            cacheFileManager?.deleteFolder(url: groupFoler)
        }
        dispose()
    }
}
