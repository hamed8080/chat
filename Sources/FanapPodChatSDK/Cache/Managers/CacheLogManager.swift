//
//  CacheLogManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

final class CacheLogManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger

    required init(context: NSManagedObjectContext, logger: Logger) {
        self.context = context
        self.logger = logger
    }

    func insert(model: Log) {
        let entity = CDLog.insertEntity(context)
        entity.update(model)
    }

    func insert(models: [Log]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int, _ completion: @escaping (CDLog?) -> Void) {
        context.perform {
            let req = CDLog.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let log = try self.context.fetch(req).first
            completion(log)
        }
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDLog]) -> Void) {
        context.perform {
            let req = CDLog.fetchRequest()
            req.predicate = predicate
            let logs = try self.context.fetch(req)
            completion(logs)
        }
    }

    func update(model _: Log, entity _: CDLog) {}

    func update(models _: [Log]) {}

    func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: CDLog.entityName)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDLog) {}

    func delete(_ models: [Log]) {
        let ids = models.compactMap(\.id.string)
        let predicate = NSPredicate(format: "id IN %@", ids)
        batchDelete(context, entityName: CDLog.entityName, predicate: predicate)
    }

    func firstLog(_ completion: @escaping (CDLog?) -> Void) {
        context.perform {
            let sortByTime = NSSortDescriptor(key: "time", ascending: true)
            let req = CDLog.fetchRequest()
            req.fetchLimit = 1
            req.sortDescriptors = [sortByTime]
            completion(try self.context.fetch(req).first)
        }
    }
}
