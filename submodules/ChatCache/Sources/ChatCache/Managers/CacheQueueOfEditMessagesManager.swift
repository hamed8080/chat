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

    public func unsendForThread(_ threadId: Int, _ count: Int = 25, _ offset: Int = 0, _ completion: @escaping @Sendable ([Entity], Int) -> Void) {
        let threadIdPredicate = NSPredicate(format: "threadId == \(CDConversation.queryIdSpecifier)", threadId.nsValue)
        let sPredicate = SendableNSPredicate(predicate: threadIdPredicate)
        fetchWithOffset(count: count, offset: offset, predicate: sPredicate, completion)
    }
}
