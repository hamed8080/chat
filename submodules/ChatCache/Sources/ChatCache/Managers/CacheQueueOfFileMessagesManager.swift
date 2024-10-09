//
// CacheQueueOfFileMessagesManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheQueueOfFileMessagesManager: BaseCoreDataManager<CDQueueOfFileMessages> {

    public func delete(_ uniqueIds: [String]) {
        let predicate = NSPredicate(format: "%K IN %@", #keyPath(CDQueueOfFileMessages.uniqueId), uniqueIds)
        batchDelete(predicate: predicate)
    }

    public func unsendForThread(_ threadId: Int, _ count: Int = 25, _ offset: Int = 0, _ completion: @escaping ([Entity], Int) -> Void) {
        let threadIdPredicate = NSPredicate(format: "threadId == \(CDConversation.queryIdSpecifier)", threadId.nsValue)
        fetchWithOffset(count: count, offset: offset, predicate: threadIdPredicate, completion)
    }
}
