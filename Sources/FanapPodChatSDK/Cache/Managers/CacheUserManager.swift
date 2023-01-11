//
//  CacheUserManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

class CacheUserManager: CoreDataProtocol {
    let idName = "id"
    let pm: PersistentManager
    var context: NSManagedObjectContext
    let logger: Logger?
    let entityName = CDUser.entity().name ?? ""

    required init(context: NSManagedObjectContext? = nil, pm: PersistentManager, logger: Logger? = nil) {
        self.context = context ?? pm.context
        self.pm = pm
        self.logger = logger
    }

    func insert(context: NSManagedObjectContext, model: User) {
        let entity = CDUser(context: context)
        entity.update(model)
    }

    func insert(models: [User]) {
        insertObjects { [weak self] bgTask in
            models.forEach { model in
                self?.insert(context: bgTask, model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int) -> CDUser? {
        let req = CDUser.fetchRequest()
        req.predicate = idPredicate(id: id)
        return try? context.fetch(req).first
    }

    func find(predicate: NSPredicate) -> [CDUser] {
        let req = CDUser.fetchRequest()
        req.predicate = predicate
        return (try? context.fetch(req)) ?? []
    }

    func update(model _: User, entity _: CDUser) {}

    func update(models _: [User]) {}

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

    func delete(entity _: CDUser) {}

    func insert(_ models: [User], isMe: Bool = false) {
        insertObjects { bgTask in
            models.forEach { model in
                let entity = CDUser(context: bgTask)
                entity.update(model)
                entity.isMe = isMe as NSNumber
            }
        }
    }
}
