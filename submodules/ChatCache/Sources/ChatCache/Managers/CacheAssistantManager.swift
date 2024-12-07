//
// CacheAssistantManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheAssistantManager: BaseCoreDataManager<CDAssistant>, @unchecked Sendable {

    public func block(block: Bool, assistants: [Entity.Model]) {
        fetchWithIntIds(assistants) { [weak self] entities in
            entities.forEach { assistant in
                assistant.block = block as NSNumber
            }
            self?.saveViewContext()
        }
    }

    public func getBlocked(_ count: Int = 25, _ offset: Int = 0, _ completion: @escaping @Sendable ([Entity], Int) -> Void) {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(CDAssistant.block), NSNumber(booleanLiteral: true))
        let sPredicate = SendableNSPredicate(predicate: predicate)
        fetchWithOffset(count: count, offset: offset, predicate: sPredicate, completion)
    }

    public func delete(_ models: [Entity.Model]) {
        fetchWithIntIds(models) { [weak self] entities in
            entities.forEach { entity in
                self?.viewContext.delete(entity)
            }
            self?.saveViewContext()
        }
    }

    private func fetchWithIntIds(_ models: [Entity.Model], _ compeletion: @escaping @Sendable ([Entity]) -> Void) {
        models.forEach { model in
            if let participantId = model.participant?.id {
                let predicate = NSPredicate(format: "%K == %@", #keyPath(CDAssistant.participant.id), participantId.nsValue)
                let sPredicate = SendableNSPredicate(predicate: predicate)
                find(predicate: sPredicate) { entities in
                    compeletion(entities)
                }
            }
        }
    }

    public func fetch(_ count: Int = 25, _ offset: Int = 0, _ completion: @escaping @Sendable ([Entity], Int) -> Void) {
        let fetchRequest = Entity.fetchRequest()
        viewContext.perform {
            let threads = try self.viewContext.fetch(fetchRequest)
            fetchRequest.fetchLimit = count
            fetchRequest.fetchOffset = offset
            let count = try self.viewContext.count(for: fetchRequest)
            completion(threads, count)
        }
    }
}
