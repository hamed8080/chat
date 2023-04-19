//
//  CacheQueueOfFileMessagesManager.swift
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

public final class CacheQueueOfFileMessagesManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger

    required init(context: NSManagedObjectContext, logger: Logger) {
        self.context = context
        self.logger = logger
    }

    func insert(model: QueueOfFileMessages) {
        let entity = CDQueueOfFileMessages.insertEntity(context)
        entity.update(model)
    }

    func insert(models: [QueueOfFileMessages]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    public func first(with id: Int, _ completion: @escaping (CDQueueOfFileMessages?) -> Void) {
        context.perform {
            let req = CDQueueOfFileMessages.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let queue = try self.context.fetch(req).first
            completion(queue)
        }
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDQueueOfFileMessages]) -> Void) {
        context.perform {
            let req = CDQueueOfFileMessages.fetchRequest()
            req.predicate = predicate
            let queues = try self.context.fetch(req)
            completion(queues)
        }
    }

    func update(model _: QueueOfFileMessages, entity _: CDQueueOfFileMessages) {}

    func update(models _: [QueueOfEditMessages]) {}

    public func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: CDQueueOfFileMessages.entityName)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDQueueOfFileMessages) {}

    public func insert(req: SendTextMessageRequest? = nil, uploadFile: UploadFileRequest) {
        insertObjects(context) { context in
            let req = QueueOfFileMessages(req: req, uploadFile: uploadFile)
            let entity = CDQueueOfFileMessages.insertEntity(context)
            entity.update(req)
        }
    }

    public func insert(req: SendTextMessageRequest? = nil, imageRequest: UploadImageRequest) {
        insertObjects(context) { context in
            let req = QueueOfFileMessages(req: req, imageRequest: imageRequest)
            let entity = CDQueueOfFileMessages.insertEntity(context)
            entity.update(req)
        }
    }

    public func delete(_ uniqueIds: [String]) {
        let predicate = NSPredicate(format: "uniqueId IN %@", uniqueIds)
        batchDelete(context, entityName: CDQueueOfFileMessages.entityName, predicate: predicate)
    }

    public func unsedForThread(_ threadId: Int?, _ count: Int?, _ offset: Int?, _ completion: @escaping ([CDQueueOfFileMessages], Int) -> Void) {
        let threadIdPredicate = NSPredicate(format: "threadId == %i", threadId ?? -1)
        fetchWithOffset(entityName: CDQueueOfFileMessages.entityName, count: count, offset: offset, predicate: threadIdPredicate, completion)
    }
}
