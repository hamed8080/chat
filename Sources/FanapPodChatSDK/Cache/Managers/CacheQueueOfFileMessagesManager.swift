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
    let pm: PersistentManager
    var context: NSManagedObjectContext
    let logger: Logger?
    let entityName = CDLog.entity().name ?? ""

    required init(context: NSManagedObjectContext? = nil, pm: PersistentManager, logger: Logger? = nil) {
        self.context = context ?? pm.context
        self.pm = pm
        self.logger = logger
    }

    func insert(context: NSManagedObjectContext, model: QueueOfFileMessages) {
        let entity = CDQueueOfFileMessages(context: context)
        entity.update(model)
    }

    func insert(models: [QueueOfFileMessages]) {
        insertObjects { [weak self] bgTask in
            models.forEach { model in
                self?.insert(context: bgTask, model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int) -> CDQueueOfFileMessages? {
        let req = CDQueueOfFileMessages.fetchRequest()
        req.predicate = idPredicate(id: id)
        return try? context.fetch(req).first
    }

    func find(predicate: NSPredicate) -> [CDQueueOfFileMessages] {
        let req = CDQueueOfFileMessages.fetchRequest()
        req.predicate = predicate
        return (try? context.fetch(req)) ?? []
    }

    func update(model _: QueueOfFileMessages, entity _: CDQueueOfFileMessages) {}

    func update(models _: [QueueOfEditMessages]) {}

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

    func delete(entity _: CDQueueOfFileMessages) {}

    func insert(req: SendTextMessageRequest? = nil, uploadFile: UploadFileRequest) {
        let req = QueueOfFileMessages(req: req, uploadFile: uploadFile)
        let entity = CDQueueOfFileMessages(context: context)
        entity.update(req)
    }

    func insert(req: SendTextMessageRequest? = nil, imageRequest: UploadImageRequest) {
        let req = QueueOfFileMessages(req: req, imageRequest: imageRequest)
        let entity = CDQueueOfFileMessages(context: context)
        entity.update(req)
    }

    func delete(_ uniqueIds: [String]) {
        let predicate = NSPredicate(format: "uniqueId IN %@", uniqueIds)
        batchDelete(entityName: entityName, predicate: predicate)
    }

    func unsedForThread(_ threadId: Int?, _ count: Int?, _ offset: Int?) -> (objects: [CDQueueOfFileMessages], totalCount: Int) {
        let threadIdPredicate = NSPredicate(format: "threadId == %i", threadId ?? -1)
        let textResponse: (objects: [CDQueueOfFileMessages], totalCount: Int) = fetchWithOffset(
            count: count,
            offset: offset,
            predicate: threadIdPredicate
        )
        return textResponse
    }
}
