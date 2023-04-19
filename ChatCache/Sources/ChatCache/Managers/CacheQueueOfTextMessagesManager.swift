//
//  CacheQueueOfTextMessagesManager.swift
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

public final class CacheQueueOfTextMessagesManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger

    required init(context: NSManagedObjectContext, logger: Logger) {
        self.context = context
        self.logger = logger
    }

    func insert(model: QueueOfTextMessages) {
        let entity = CDQueueOfTextMessages.insertEntity(context)
        entity.update(model)
    }

    public func insert(models: [QueueOfTextMessages]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    public func first(with id: Int, _ completion: @escaping (CDQueueOfTextMessages?) -> Void) {
        context.perform {
            let req = CDQueueOfTextMessages.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let queue = try self.context.fetch(req).first
            completion(queue)
        }
    }

    public func find(predicate: NSPredicate, _ completion: @escaping ([CDQueueOfTextMessages]) -> Void) {
        context.perform {
            let req = CDQueueOfTextMessages.fetchRequest()
            req.predicate = predicate
            let queues = try self.context.fetch(req)
            completion(queues)
        }
    }

    func update(model _: QueueOfTextMessages, entity _: CDQueueOfTextMessages) {}

    func update(models _: [QueueOfTextMessages]) {}

    public func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: CDQueueOfTextMessages.entityName)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDQueueOfTextMessages) {}

    public func insert(_ req: SendTextMessageRequest) {
        let model = QueueOfTextMessages(textRequest: req)
        insert(models: [model])
    }

    public func delete(_ uniqueIds: [String]) {
        let predicate = NSPredicate(format: "uniqueId IN %@", uniqueIds)
        batchDelete(context, entityName: CDQueueOfTextMessages.entityName, predicate: predicate)
    }

    public func unsendForThread(_ threadId: Int?, _ count: Int?, _ offset: Int?, _ completion: @escaping ([CDQueueOfTextMessages], Int) -> Void) {
        let threadIdPredicate = NSPredicate(format: "threadId == %i", threadId ?? -1)
        fetchWithOffset(entityName: CDQueueOfTextMessages.entityName, count: count, offset: offset, predicate: threadIdPredicate, completion)
    }
}
