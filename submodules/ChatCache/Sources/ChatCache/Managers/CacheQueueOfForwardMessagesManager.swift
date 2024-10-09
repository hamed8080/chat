//
// CacheQueueOfForwardMessagesManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheQueueOfForwardMessagesManager: BaseCoreDataManager<CDQueueOfForwardMessages> {

    public func delete(_ uniqueIds: [String]) {
        let uniqueIds = uniqueIds.joined(separator: ",")
        let sanitizedString = sanitizeUniqueIds(uniqueIds)
        let predicate = NSPredicate(format: "%K CONTAINS %@", #keyPath(CDQueueOfForwardMessages.uniqueIds), sanitizedString)
        batchDelete(predicate: predicate)
    }

    /// We do this as a result of some uniqueIds in the message queue object may contain a stringed version of uniqueIds with ["123", "345"] which contains semicolons and brackets, and spaces.
    func sanitizeUniqueIds(_ uniqueIds: String) -> String {
           return uniqueIds
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: " ", with: "")
    }

    public func unsendForThread(_ threadId: Int, _ count: Int = 25, _ offset: Int = 0, _ completion: @escaping ([Entity], Int) -> Void) {
        let threadIdPredicate = NSPredicate(format: "threadId == \(CDConversation.queryIdSpecifier)", threadId.nsValue)
        fetchWithOffset(count: count, offset: offset, predicate: threadIdPredicate, completion)
    }
}
