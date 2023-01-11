//
//  CacheQueueOfForwardMessagesManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

class CacheQueueOfForwardMessagesManager: CoreDataProtocol {
    let idName = "id"
    let pm: PersistentManager
    var context: NSManagedObjectContext
    let logger: Logger?
    let entityName = CDLog.entity().name ?? ""

    required init(context: NSManagedObjectContext? = nil, pm: PersistentManager, logger: Logger? = nil) {
        self.context = context ?? pm.context
        self.pm = pm
        self.logger = logger
    }

    func insert(context: NSManagedObjectContext, model: QueueOfForwardMessages) {
        let entity = CDQueueOfForwardMessages(context: context)
        entity.update(model)
    }

    func insert(models: [QueueOfForwardMessages]) {
        insertObjects { [weak self] bgTask in
            models.forEach { model in
                self?.insert(context: bgTask, model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int) -> CDQueueOfForwardMessages? {
        let req = CDQueueOfForwardMessages.fetchRequest()
        req.predicate = idPredicate(id: id)
        return try? context.fetch(req).first
    }

    func find(predicate: NSPredicate) -> [CDQueueOfForwardMessages] {
        let req = CDQueueOfForwardMessages.fetchRequest()
        req.predicate = predicate
        return (try? context.fetch(req)) ?? []
    }

    func update(model _: QueueOfForwardMessages, entity _: CDQueueOfForwardMessages) {}

    func update(models _: [QueueOfForwardMessages]) {}

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

    func delete(entity _: CDQueueOfForwardMessages) {}

    func insert(_ forward: ForwardMessageRequest) {
        let model = QueueOfForwardMessages(forward: forward)
        insert(models: [model])
    }

    func delete(_ uniqueIds: [String]) {
        let predicate = NSPredicate(format: "uniqueIds CONTAINS %@", uniqueIds)
        batchDelete(entityName: entityName, predicate: predicate)
    }

    func unsedForThread(_ threadId: Int?, _ count: Int?, _ offset: Int?) -> (objects: [CDQueueOfForwardMessages], totalCount: Int) {
        let threadIdPredicate = NSPredicate(format: "threadId == %i", threadId ?? -1)
        let textResponse: (objects: [CDQueueOfForwardMessages], totalCount: Int) = fetchWithOffset(
            count: count,
            offset: offset,
            predicate: threadIdPredicate
        )
        return textResponse
    }
}
