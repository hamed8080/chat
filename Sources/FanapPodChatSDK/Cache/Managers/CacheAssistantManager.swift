//
//  CacheAssistantManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

class CacheAssistantManager: CoreDataProtocol {
    let idName = "id"
    let pm: PersistentManager
    var context: NSManagedObjectContext?
    let logger: Logger?
    let entityName = CDAssistant.entity().name ?? "CDAssistant"

    required init(context: NSManagedObjectContext? = nil, pm: PersistentManager, logger: Logger? = nil) {
        self.context = context ?? pm.context
        self.pm = pm
        self.logger = logger
    }

    func insert(context: NSManagedObjectContext, model: Assistant) {
        let entity = CDAssistant(context: context)
        entity.update(model)
    }

    func insert(models: [Assistant]) {
        insertObjects { [weak self] bgTask in
            models.forEach { model in
                self?.insert(context: bgTask, model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int) -> CDAssistant? {
        let req = CDAssistant.fetchRequest()
        req.predicate = idPredicate(id: id)
        return try? context?.fetch(req).first
    }

    func find(predicate: NSPredicate) -> [CDAssistant] {
        let req = CDAssistant.fetchRequest()
        req.predicate = predicate
        return (try? context?.fetch(req)) ?? []
    }

    func update(model _: Assistant, entity _: CDAssistant) {}

//    func update(models: [Assistant]) {
//        let predicate = NSPredicate(format: "id IN == @i", models.compactMap { $0.id as? NSNumber })
//    }

    func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate { [weak self] bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: self?.entityName ?? "")
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDAssistant) {}

    func block(block: Bool, assistants: [Assistant]) {
        let predicate = NSPredicate(format: "id IN == @i", assistants.compactMap { $0.participant?.id as? NSNumber })
        let propertiesToUpdate = ["block": block as NSNumber]
        update(propertiesToUpdate, predicate)
    }

    func getBlocked(_ count: Int?, _ offset: Int?) -> (objects: [CDAssistant], totalCount: Int) {
        let predicate = NSPredicate(format: "block == %@", NSNumber(booleanLiteral: true))
        return fetchWithOffset(count: count, offset: offset, predicate: predicate)
    }

    func delete(_ models: [Assistant]) {
        let predicate = NSPredicate(format: "id IN == @i", models.compactMap { $0.id as? NSNumber })
        batchDelete(entityName: entityName, predicate: predicate)
    }
}
