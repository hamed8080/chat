//
//  CacheLogManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

class CacheLogManager: CoreDataProtocol {
    let idName = "id"
    let pm: PersistentManager
    var context: NSManagedObjectContext
    let logger: Logger?
    let entityName = CDLog.entity().name ?? ""

    required init(context: NSManagedObjectContext? = nil, pm: PersistentManager, logger: Logger? = nil) {
        self.context = context ?? pm.context
        self.pm = pm
        self.logger = logger
    }

    func insert(context: NSManagedObjectContext, model: Log) {
        let entity = CDLog(context: context)
        entity.update(model)
    }

    func insert(models: [Log]) {
        insertObjects { [weak self] bgTask in
            models.forEach { model in
                self?.insert(context: bgTask, model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int) -> CDLog? {
        let req = CDLog.fetchRequest()
        req.predicate = idPredicate(id: id)
        return try? context.fetch(req).first
    }

    func find(predicate: NSPredicate) -> [CDLog] {
        let req = CDLog.fetchRequest()
        req.predicate = predicate
        return (try? context.fetch(req)) ?? []
    }

    func update(model _: Log, entity _: CDLog) {}

    func update(models _: [Log]) {}

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

    func delete(entity _: CDLog) {}

    func delete(_ models: [Log]) {
        let ids = models.compactMap(\.id.string)
        let predicate = NSPredicate(format: "id IN %i", ids)
        batchDelete(entityName: entityName, predicate: predicate)
    }

    func firstLog() -> CDLog? {
        let sortByTime = NSSortDescriptor(key: "time", ascending: true)
        let req = CDLog.fetchRequest()
        req.fetchLimit = 1
        req.sortDescriptors = [sortByTime]
        return try? context.fetch(req).first
    }
}
