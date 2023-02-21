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
    var context: NSManagedObjectContext
    let logger: Logger?
    let entityName = CDUser.entity().name ?? "CDUser"

    required init(context: NSManagedObjectContext, logger: Logger? = nil) {
        self.context = context
        self.logger = logger
    }

    func insert(model: User) {
        let entity = CDUser(context: context)
        entity.update(model)
    }

    func insert(models: [User]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int, _ completion: @escaping (CDUser?) -> Void) {
        context.perform {
            let req = CDUser.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let user = try? self.context.fetch(req).first
            completion(user)
        }
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDUser]) -> Void) {
        context.perform {
            let req = CDUser.fetchRequest()
            req.predicate = predicate
            let users = (try? self.context.fetch(req)) ?? []
            completion(users)
        }
    }

    func update(model _: User, entity _: CDUser) {}

    func update(models _: [User]) {}

    func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { [weak self] bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: self?.entityName ?? "")
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDUser) {}

    func insert(_ models: [User], isMe: Bool = false) {
        insertObjects(context) { bgTask in
            models.forEach { model in
                let entity = CDUser(context: bgTask)
                entity.update(model)
                entity.isMe = isMe as NSNumber
            }
        }
    }
}
