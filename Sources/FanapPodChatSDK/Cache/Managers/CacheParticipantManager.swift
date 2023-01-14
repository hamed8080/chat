//
//  CacheParticipantManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

class CacheParticipantManager: CoreDataProtocol {
    let idName = "id"
    let pm: PersistentManager
    var context: NSManagedObjectContext
    let logger: Logger?
    let entityName = CDParticipant.entity().name ?? ""

    required init(context: NSManagedObjectContext? = nil, pm: PersistentManager, logger: Logger? = nil) {
        self.context = context ?? pm.context
        self.pm = pm
        self.logger = logger
    }

    func insert(context: NSManagedObjectContext, model: Participant) {
        let entity = CDParticipant(context: context)
        entity.update(model)
    }

    func insert(models: [Participant]) {
        insertObjects { [weak self] bgTask in
            models.forEach { model in
                self?.insert(context: bgTask, model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int) -> CDParticipant? {
        let req = CDParticipant.fetchRequest()
        req.predicate = idPredicate(id: id)
        return try? context.fetch(req).first
    }

    func find(predicate: NSPredicate) -> [CDParticipant] {
        let req = CDParticipant.fetchRequest()
        req.predicate = predicate
        return (try? context.fetch(req)) ?? []
    }

    func update(model _: Participant, entity _: CDParticipant) {}

    func update(models _: [CDParticipant]) {}

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

    func delete(entity _: CDParticipant) {}

    func getParticipantsForThread(_ threadId: Int?, _ count: Int?, _ offset: Int?) -> (objects: [CDParticipant], totalCount: Int) {
        let predicate = NSPredicate(format: "threadId == %i", threadId ?? -1)
        return fetchWithOffset(count: count, offset: offset, predicate: predicate)
    }

    func delete(_ models: [Participant]) {
        let ids = models.compactMap(\.id)
        let predicate = NSPredicate(format: "id IN %i", ids)
        batchDelete(entityName: entityName, predicate: predicate)
    }
}
