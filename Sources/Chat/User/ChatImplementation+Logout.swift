//
// ChatImplementation+Logout.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import ChatCore
import ChatDTO
import ChatModels
import Foundation

// Request
public extension ChatImplementation {
    /// Tell the server user has logged out. This method wil **truncate and delete** all data inside the cache.
    func logOut() {
        let req = BareChatSendableRequest(uniqueId: UUID().uuidString)
        prepareToSendAsync(req: req, type: .logout)
        cache?.delete()
        if let docFoler = cacheFileManager?.documentPath {
            cacheFileManager?.deleteFolder(url: docFoler)
        }

        if let groupFoler = cacheFileManager?.groupFolder {
            cacheFileManager?.deleteFolder(url: groupFoler)
        }
        dispose()
    }
}
