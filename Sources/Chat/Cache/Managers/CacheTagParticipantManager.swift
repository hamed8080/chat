//
//  CacheTagParticipantManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation
import Logger

final class CacheTagParticipantManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger

    required init(context: NSManagedObjectContext, logger: Logger) {
        self.context = context
        self.logger = logger
    }

    func insert(model: TagParticipant) {
        let entity = CDTagParticipant.insertEntity(context)
        entity.update(model)
    }

    func insert(models: [TagParticipant]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int, _ completion: @escaping (CDTagParticipant?) -> Void) {
        context.perform {
            let req = CDTagParticipant.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let tagParticipant = try self.context.fetch(req).first
            completion(tagParticipant)
        }
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDTagParticipant]) -> Void) {
        context.perform {
            let req = CDTagParticipant.fetchRequest()
            req.predicate = predicate
            let tagParticipants = try self.context.fetch(req)
            completion(tagParticipants)
        }
    }

    func update(model _: TagParticipant, entity _: CDTagParticipant) {}

    func update(models _: [TagParticipant]) {}

    func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: CDTagParticipant.entityName)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDTagParticipant) {}

    func delete(_ models: [TagParticipant]) {
        let ids = models.compactMap(\.id)
        let predicate = NSPredicate(format: "id IN %@", ids)
        batchDelete(context, entityName: CDTagParticipant.entityName, predicate: predicate)
    }
}
