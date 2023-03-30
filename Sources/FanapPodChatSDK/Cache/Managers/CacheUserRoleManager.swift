//
//  CacheUserRoleManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

final class CacheUserRoleManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger

    required init(context: NSManagedObjectContext, logger: Logger) {
        self.context = context
        self.logger = logger
    }

    func insert(model: UserRole) {
        let entity = CDUserRole.insertEntity(context)
        entity.update(model)
    }

    func insert(models: [UserRole]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int, _ completion: @escaping (CDUserRole?) -> Void) {
        context.perform {
            let req = CDUserRole.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let userRole = try self.context.fetch(req).first
            completion(userRole)
        }
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDUserRole]) -> Void) {
        context.perform {
            let req = CDUserRole.fetchRequest()
            req.predicate = predicate
            let userRoles = try self.context.fetch(req)
            completion(userRoles)
        }
    }

    func update(model _: UserRole, entity _: CDUserRole) {}

    func update(models _: [UserRole]) {}

    func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: CDUserRole.entityName)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDUserRole) {}

    func roles(_ threadId: Int) -> [Roles] {
        let req = CDUserRole.fetchRequest()
        req.predicate = NSPredicate(format: "threadId == %i", threadId)
        let roles = (try? context.fetch(req))?.first?.codable.roles
        return roles ?? []
    }
}
