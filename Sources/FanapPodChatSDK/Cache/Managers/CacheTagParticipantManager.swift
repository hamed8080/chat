//
//  CacheTagParticipantManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

class CacheTagParticipantManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger?
    let entityName = CDTagParticipant.entity().name ?? "CDTagParticipant"

    required init(context: NSManagedObjectContext, logger: Logger? = nil) {
        self.context = context
        self.logger = logger
    }

    func insert(model: TagParticipant) {
        let entity = CDTagParticipant(context: context)
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
            let tagParticipant = try? self.context.fetch(req).first
            completion(tagParticipant)
        }
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDTagParticipant]) -> Void) {
        context.perform {
            let req = CDTagParticipant.fetchRequest()
            req.predicate = predicate
            let tagParticipants = (try? self.context.fetch(req)) ?? []
            completion(tagParticipants)
        }
    }

    func update(model _: TagParticipant, entity _: CDTagParticipant) {}

    func update(models _: [TagParticipant]) {}

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

    func delete(entity _: CDTagParticipant) {}

    func delete(_ models: [TagParticipant]) {
        let ids = models.compactMap(\.id)
        let predicate = NSPredicate(format: "id IN %@", ids)
        batchDelete(context, entityName: entityName, predicate: predicate)
    }
}
