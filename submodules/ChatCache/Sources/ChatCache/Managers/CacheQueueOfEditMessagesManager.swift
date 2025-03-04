//
// CacheQueueOfEditMessagesManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheQueueOfEditMessagesManager: BaseCoreDataManager<CDQueueOfEditMessages>, @unchecked Sendable {

    public func delete(_ uniqueIds: [String]) {
        let predicate = NSPredicate(format: "%K IN %@", #keyPath(CDQueueOfEditMessages.uniqueId), uniqueIds)
        batchDelete(predicate: predicate)
    }

    @MainActor
    public func unsendForThread(_ threadId: Int, _ count: Int = 25, _ offset: Int = 0) -> ([Entity]?, Int)? {
        let threadIdPredicate = NSPredicate(format: "threadId == \(CDConversation.queryIdSpecifier)", threadId.nsValue)
        let sPredicate = SendableNSPredicate(predicate: threadIdPredicate)
        return fetchWithOffset(count: count, offset: offset, predicate: sPredicate)
    }
}
