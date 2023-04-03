//
//  CacheTagManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation
import Logger

final class CacheTagManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger

    required init(context: NSManagedObjectContext, logger: Logger) {
        self.context = context
        self.logger = logger
    }

    func insert(model: Tag) {
        let entity = CDTag.insertEntity(context)
        entity.update(model)
    }

    func insert(models: [Tag]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int, _ completion: @escaping (CDTag?) -> Void) {
        context.perform {
            let req = CDTag.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let tag = try self.context.fetch(req).first
            completion(tag)
        }
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDTag]) -> Void) {
        context.perform {
            let req = CDTag.fetchRequest()
            req.predicate = predicate
            let tags = try self.context.fetch(req)
            completion(tags)
        }
    }

    func update(model _: Tag, entity _: CDTag) {}

    func update(models _: [Tag]) {}

    func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: CDTag.entityName)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDTag) {}

    func getTags(_ completion: @escaping ([CDTag]) -> Void) {
        context.perform {
            let req = CDTag.fetchRequest()
            let tags = try self.context.fetch(req)
            completion(tags)
        }
    }

    func delete(_ id: Int?) {
        let predicate = idPredicate(id: id ?? -1)
        batchDelete(context, entityName: CDTag.entityName, predicate: predicate)
    }
}
