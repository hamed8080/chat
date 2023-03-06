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
    var context: NSManagedObjectContext
    let logger: Logger?

    required init(context: NSManagedObjectContext, logger: Logger? = nil) {
        self.context = context
        self.logger = logger
    }

    func insert(model: Assistant) {
        let entity = CDAssistant.insertEntity(context)
        entity.update(model)
    }

    func insert(models: [Assistant]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int, _ completion: @escaping (CDAssistant?) -> Void) {
        context.perform {
            let req = CDAssistant.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let assistant = try self.context.fetch(req).first
            completion(assistant)
        }
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDAssistant]) -> Void) {
        context.perform {
            let req = CDAssistant.fetchRequest()
            req.predicate = predicate
            let contacts = try self.context.fetch(req)
            completion(contacts)
        }
    }

    func update(model _: Assistant, entity _: CDAssistant) {}

//    func update(models: [Assistant]) {
//        let predicate = NSPredicate(format: "id IN == @i", models.compactMap { $0.id as? NSNumber })
//    }

    func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: CDAssistant.entityName)
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

    func getBlocked(_ count: Int?, _ offset: Int?, _ completion: @escaping ([CDAssistant], Int) -> Void) {
        let predicate = NSPredicate(format: "block == %@", NSNumber(booleanLiteral: true))
        fetchWithOffset(entityName: CDAssistant.entityName, count: count, offset: offset, predicate: predicate, completion)
    }

    func delete(_ models: [Assistant]) {
        let predicate = NSPredicate(format: "id IN == @i", models.compactMap { $0.id as? NSNumber })
        batchDelete(context, entityName: CDAssistant.entityName, predicate: predicate)
    }
}
