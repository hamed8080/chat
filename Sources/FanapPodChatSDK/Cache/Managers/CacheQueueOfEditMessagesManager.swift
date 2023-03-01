//
//  CacheQueueOfEditMessagesManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

class CacheQueueOfEditMessagesManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger?
    let entityName = CDQueueOfEditMessages.entity().name ?? "CDQueueOfEditMessages"

    required init(context: NSManagedObjectContext, logger: Logger? = nil) {
        self.context = context
        self.logger = logger
    }

    func insert(model: QueueOfEditMessages) {
        let entity = CDQueueOfEditMessages(context: context)
        entity.update(model)
    }

    func insert(models: [QueueOfEditMessages]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int, _ completion: @escaping (CDQueueOfEditMessages?) -> Void) {
        context.perform {
            let req = CDQueueOfEditMessages.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let queue = try self.context.fetch(req).first
            completion(queue)
        }
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDQueueOfEditMessages]) -> Void) {
        context.perform {
            let req = CDQueueOfEditMessages.fetchRequest()
            req.predicate = predicate
            let queues = try self.context.fetch(req)
            completion(queues)
        }
    }

    func update(model _: QueueOfEditMessages, entity _: CDQueueOfEditMessages) {}

    func update(models _: [QueueOfEditMessages]) {}

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

    func delete(entity _: CDQueueOfEditMessages) {}

    func insert(_ edit: EditMessageRequest) {
        insert(models: [QueueOfEditMessages(edit: edit)])
    }

    func delete(_ uniqueIds: [String]) {
        let predicate = NSPredicate(format: "uniqueId IN %@", uniqueIds)
        batchDelete(context, entityName: entityName, predicate: predicate)
    }

    func unsedForThread(_ threadId: Int?, _ count: Int?, _ offset: Int?, _ completion: @escaping ([CDQueueOfEditMessages], Int) -> Void) {
        let threadIdPredicate = NSPredicate(format: "threadId == %i", threadId ?? -1)
        fetchWithOffset(count: count, offset: offset, predicate: threadIdPredicate, completion)
    }
}
