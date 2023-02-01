//
//  CacheCoreDataFileManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

class CacheCoreDataFileManager: CoreDataProtocol {
    let idName = "hashCode"
    let pm: PersistentManager
    var context: NSManagedObjectContext?
    let logger: Logger?
    let entityName = CDFile.entity().name ?? "CDFile"

    required init(context: NSManagedObjectContext? = nil, pm: PersistentManager, logger: Logger? = nil) {
        self.context = context ?? pm.context
        self.pm = pm
        self.logger = logger
    }

    func insert(context: NSManagedObjectContext, model: File) {
        let entity = CDFile(context: context)
        entity.update(model)
    }

    func insert(models: [File]) {
        insertObjects { [weak self] bgTask in
            models.forEach { model in
                self?.insert(context: bgTask, model: model)
            }
        }
    }

    func idPredicate(id: String) -> NSPredicate {
        NSPredicate(format: "\(idName) == %@", id)
    }

    func first(with id: String) -> CDFile? {
        let req = CDFile.fetchRequest()
        req.predicate = idPredicate(id: id)
        return try? context?.fetch(req).first
    }

    func find(predicate: NSPredicate) -> [CDFile] {
        let req = CDFile.fetchRequest()
        req.predicate = predicate
        return (try? context?.fetch(req)) ?? []
    }

    func update(model _: File, entity _: CDFile) {}

    func update(models _: [File]) {}

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

    func delete(entity _: CDFile) {}
}
