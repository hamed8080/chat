//
// CacheReactionCountManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheReactionCountManager: BaseCoreDataManager<CDReactionCountList>, @unchecked Sendable {
    
    @MainActor
    public func fetch(_ messageIds: [Int]) -> [Entity]? {
        let predicate = NSPredicate(format: "%K IN %@", #keyPath(CDReactionCountList.messageId), messageIds)
        let sPredicate = SendableNSPredicate(predicate: predicate)
        return find(predicate: sPredicate)
    }
   
    @MainActor
    public func setReactionCount(model: CacheReactionCountModel) {
        switch model.action {
        case .add:
            self.addReaction(model)
        case .delete:
            self.deleteReaction(model)
        case .replace:
            self.replaceReaction(model)
        }
    }
    
    @MainActor
    private func replaceReaction(_ model: CacheReactionCountModel) {
        /// Keep a reference copy of the model to proeprly set reaction property to old reaction sticker
        var deletedReactionModel = model
        deletedReactionModel.reaction = .init(id: model.reaction?.id,
                                              reaction: model.oldSticker,
                                              participant: model.reaction?.participant,
                                              time: model.reaction?.time)
        deleteReaction(model)
        addReaction(model)
    }
    
    @MainActor
    private func addReaction(_ model: CacheReactionCountModel) {
        let entity = first(with: model.messageId.nsValue)
        guard let reaction = model.reaction else { return }
        let isMyReaction = reaction.participant?.id == model.myUserId
        
        if let entity = entity {
            var reactionCounts = entity.codable.reactionCounts ?? []
            if let index = reactionCounts.firstIndex(where: { $0.sticker == reaction.reaction }) {
                /// Update reaction count
                reactionCounts[index].count = (reactionCounts[index].count ?? 0) + 1
            } else {
                /// There were other reactions in the list but there were not any reaction with this sticker so we add a new one
                reactionCounts.append(.init(sticker: reaction.reaction, count: 1))
            }
            
            entity.update(.init(messageId: model.messageId,
                                reactionCounts: reactionCounts,
                                userReaction: isMyReaction ? reaction : entity.codable.userReaction))
        } else {
            /// Insert reaction count for the first time
            let newReactionEntity = Entity.insertEntity(viewContext)
            let reactionCounts: [ReactionCount] = [.init(sticker: reaction.reaction, count: 1)]
            newReactionEntity.update(.init(messageId: model.messageId, reactionCounts: reactionCounts, userReaction: isMyReaction ? reaction : nil))
        }
        saveViewContext()
    }
    
    @MainActor
    private func deleteReaction(_ model: CacheReactionCountModel ) {
        guard
            let entity = first(with: model.messageId.nsValue),
                let reaction = model.reaction,
            var reactionCounts = entity.codable.reactionCounts,
            let index = reactionCounts.firstIndex(where: { $0.sticker == reaction.reaction })
        else { return }
        
        /// Reduce current reaction count
        let isMyReactionDeleted = reaction.participant?.id == model.myUserId
        let currentCount = reactionCounts[index].count ?? 0
        let newValue = max(0, currentCount - 1)
        reactionCounts[index].count = newValue
        
        /// Remove reactionCount from array if it was zero
        if newValue == 0 {
            reactionCounts.remove(at: index)
        }
        
        if reactionCounts.isEmpty {
            viewContext.delete(entity)
        } else {
            entity.update(.init(messageId: model.messageId,
                                reactionCounts: reactionCounts,
                                userReaction: isMyReactionDeleted ? nil : entity.codable.userReaction))
        }
        
        saveViewContext()
    }
}
