//
//  CacheQueueOfForwardMessagesManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation
import Logger
import ChatDTO
import ChatModels
import ChatExtensions

public final class CacheQueueOfForwardMessagesManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger

    required init(context: NSManagedObjectContext, logger: Logger) {
        self.context = context
        self.logger = logger
    }

    func insert(model: QueueOfForwardMessages) {
        let entity = CDQueueOfForwardMessages.insertEntity(context)
        entity.update(model)
    }

    public func insert(models: [QueueOfForwardMessages]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    public func first(with id: Int, _ completion: @escaping (CDQueueOfForwardMessages?) -> Void) {
        context.perform {
            let req = CDQueueOfForwardMessages.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let queue = try self.context.fetch(req).first
            completion(queue)
        }
    }

    public func find(predicate: NSPredicate, _ completion: @escaping ([CDQueueOfForwardMessages]) -> Void) {
        context.perform {
            let req = CDQueueOfForwardMessages.fetchRequest()
            req.predicate = predicate
            let queues = try self.context.fetch(req)
            completion(queues)
        }
    }

    func update(model _: QueueOfForwardMessages, entity _: CDQueueOfForwardMessages) {}

    func update(models _: [QueueOfForwardMessages]) {}

    public func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: CDQueueOfForwardMessages.entityName)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDQueueOfForwardMessages) {}

    public func insert(_ forward: ForwardMessageRequest) {
        let model = QueueOfForwardMessages(forward: forward)
        insert(models: [model])
    }

    public func delete(_ uniqueIds: [String]) {
        let predicate = NSPredicate(format: "uniqueIds CONTAINS %@", uniqueIds)
        batchDelete(context, entityName: CDQueueOfForwardMessages.entityName, predicate: predicate)
    }

    public func unsedForThread(_ threadId: Int?, _ count: Int?, _ offset: Int?, _ completion: @escaping ([CDQueueOfForwardMessages], Int) -> Void) {
        let threadIdPredicate = NSPredicate(format: "threadId == %i", threadId ?? -1)
        fetchWithOffset(entityName: CDQueueOfForwardMessages.entityName, count: count, offset: offset, predicate: threadIdPredicate, completion)
    }
}
