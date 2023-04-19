//
//  CacheImageManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation
import Logger
import ChatModels

public final class CacheImageManager: CoreDataProtocol {
    let idName = "hashCode"
    var context: NSManagedObjectContext
    let logger: Logger

    required init(context: NSManagedObjectContext, logger: Logger) {
        self.context = context
        self.logger = logger
    }

    func insert(model: Image) {
        let entity = CDImage.insertEntity(context)
        entity.update(model)
    }

    public func insert(models: [Image]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: String) -> NSPredicate {
        NSPredicate(format: "\(idName) == %@", id)
    }

    public func first(with id: String, _ completion: @escaping (CDImage?) -> Void) {
        context.perform {
            let req = CDImage.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let image = try self.context.fetch(req).first
            completion(image)
        }
    }

    public func find(predicate: NSPredicate, _ completion: @escaping ([CDImage]) -> Void) {
        context.perform {
            let req = CDImage.fetchRequest()
            req.predicate = predicate
            let images = try self.context.fetch(req)
            completion(images)
        }
    }

    func update(model _: Image, entity _: CDImage) {}

    func update(models _: [Image]) {}

    public func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: CDImage.entityName)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDImage) {}
}
