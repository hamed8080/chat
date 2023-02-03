//
//  CacheQueueOfFileMessagesManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

class CacheQueueOfFileMessagesManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger?
    let entityName = CDQueueOfFileMessages.entity().name ?? "CDQueueOfFileMessages"

    required init(context: NSManagedObjectContext, logger: Logger? = nil) {
        self.context = context
        self.logger = logger
    }

    func insert(model: QueueOfFileMessages) {
        let entity = CDQueueOfFileMessages(context: context)
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

    func first(with id: Int, _ completion: @escaping (CDQueueOfFileMessages?) -> Void) {
        context.perform {
            let req = CDQueueOfFileMessages.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let queue = try? self.context.fetch(req).first
            completion(queue)
        }
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDQueueOfFileMessages]) -> Void) {
        context.perform {
            let req = CDQueueOfFileMessages.fetchRequest()
            req.predicate = predicate
            let queues = (try? self.context.fetch(req)) ?? []
            completion(queues)
        }
    }

    func update(model _: QueueOfFileMessages, entity _: CDQueueOfFileMessages) {}

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

    func delete(entity _: CDQueueOfFileMessages) {}

    func insert(req: SendTextMessageRequest? = nil, uploadFile: UploadFileRequest) {
        insertObjects(context) { context in
            let req = QueueOfFileMessages(req: req, uploadFile: uploadFile)
            let entity = CDQueueOfFileMessages(context: context)
            entity.update(req)
        }
    }

    func insert(req: SendTextMessageRequest? = nil, imageRequest: UploadImageRequest) {
        insertObjects(context) { context in
            let req = QueueOfFileMessages(req: req, imageRequest: imageRequest)
            let entity = CDQueueOfFileMessages(context: context)
            entity.update(req)
        }
    }

    func delete(_ uniqueIds: [String]) {
        let predicate = NSPredicate(format: "uniqueId IN %@", uniqueIds)
        batchDelete(context, entityName: entityName, predicate: predicate)
    }

    func unsedForThread(_ threadId: Int?, _ count: Int?, _ offset: Int?, _ completion: @escaping ([CDQueueOfFileMessages], Int) -> Void) {
        let threadIdPredicate = NSPredicate(format: "threadId == %i", threadId ?? -1)
        fetchWithOffset(count: count, offset: offset, predicate: threadIdPredicate, completion)
    }
}
