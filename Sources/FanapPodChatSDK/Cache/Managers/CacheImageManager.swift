//
//  CacheImageManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

class CacheImageManager: CoreDataProtocol {
    let idName = "hashCode"
    let pm: PersistentManager
    var context: NSManagedObjectContext?
    let logger: Logger?
    let entityName = CDImage.entity().name ?? "CDImage"

    required init(context: NSManagedObjectContext? = nil, pm: PersistentManager, logger: Logger? = nil) {
        self.context = context ?? pm.context
        self.pm = pm
        self.logger = logger
    }

    func insert(context: NSManagedObjectContext, model: Image) {
        let entity = CDImage(context: context)
        entity.update(model)
    }

    func insert(models: [Image]) {
        insertObjects { [weak self] bgTask in
            models.forEach { model in
                self?.insert(context: bgTask, model: model)
            }
        }
    }

    func idPredicate(id: String) -> NSPredicate {
        NSPredicate(format: "\(idName) == %@", id)
    }

    func first(with id: String) -> CDImage? {
        let req = CDImage.fetchRequest()
        req.predicate = idPredicate(id: id)
        return try? context?.fetch(req).first
    }

    func find(predicate: NSPredicate) -> [CDImage] {
        let req = CDImage.fetchRequest()
        req.predicate = predicate
        return (try? context?.fetch(req)) ?? []
    }

    func update(model _: Image, entity _: CDImage) {}

    func update(models _: [Image]) {}

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

    func delete(entity _: CDImage) {}
}
