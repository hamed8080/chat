//
// CacheAssistantManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheAssistantManager: BaseCoreDataManager<CDAssistant>, @unchecked Sendable {

    @MainActor
    public func block(block: Bool, assistants: [Entity.Model]) {
        let entities = fetchWithIntIds(assistants)
        entities.forEach { assistant in
            assistant.block = block as NSNumber
        }
        saveViewContext()
    }

    @MainActor
    public func getBlocked(_ count: Int = 25, _ offset: Int = 0) -> ([Entity]?, Int)? {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(CDAssistant.block), NSNumber(booleanLiteral: true))
        let sPredicate = SendableNSPredicate(predicate: predicate)
        return fetchWithOffset(count: count, offset: offset, predicate: sPredicate)
    }

    @MainActor
    public func delete(_ models: [Entity.Model]) {
        let entities = fetchWithIntIds(models)
        entities.forEach { entity in
            viewContext.delete(entity)
        }
        saveViewContext()
    }

    @MainActor
    private func fetchWithIntIds(_ models: [Entity.Model]) -> [Entity] {
        var entities: [Entity] = []
        models.forEach { model in
            if let participantId = model.participant?.id {
                let predicate = NSPredicate(format: "%K == %@", #keyPath(CDAssistant.participant.id), participantId.nsValue)
                let sPredicate = SendableNSPredicate(predicate: predicate)
                if let entity = find(predicate: sPredicate)?.first {
                    entities.append(entity)
                }
            }
        }
        return entities
    }

    @MainActor
    public func fetch(_ count: Int = 25, _ offset: Int = 0) -> ([Entity], Int)? {
        let fetchRequest = Entity.fetchRequest()
        let threads = try? self.viewContext.fetch(fetchRequest)
        fetchRequest.fetchLimit = count
        fetchRequest.fetchOffset = offset
        guard
            let threads = threads,
            let count = try? self.viewContext.count(for: fetchRequest)
        else { return nil }
        return (threads, count)
    }
}
