//
// CacheReactionCountManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheReactionCountManager: BaseCoreDataManager<CDReactionCountList> {

    public func fetch(_ messageIds: [Int], _ compeletion: @escaping ([Entity]) -> Void) {
        let predicate = NSPredicate(format: "%K IN %@", #keyPath(CDReactionCountList.messageId), messageIds)
        find(predicate: predicate) { entities in
            compeletion(entities)
        }
    }

    public func setReactionCount(messageId: Int?, reaction: Sticker?, action: ReactionCountAction) {
        guard let messageId = messageId else { return }
        firstOnMain(with: messageId.nsValue, context: viewContext) { entity in
            let reactionCounts = entity?.codable.reactionCounts
            if var reactionCounts = reactionCounts, let index = reactionCounts.firstIndex(where: { $0.sticker == reaction }) {
                let currentCount = reactionCounts[index].count ?? 0
                switch action {
                case .increase:
                    reactionCounts[index].count = max(0, (currentCount) + 1)
                case .decrease:
                    reactionCounts[index].count = max(0, (currentCount) - 1)
                case .set(let value):
                    reactionCounts[index].count = max(0, value)
                }
            }
        }
    }
}
