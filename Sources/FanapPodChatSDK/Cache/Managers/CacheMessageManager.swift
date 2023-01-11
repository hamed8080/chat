//
//  CacheMessageManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

class CacheMessageManager: CoreDataProtocol {
    let idName = "id"
    let pm: PersistentManager
    var context: NSManagedObjectContext
    let logger: Logger?
    let entityName = CDMessage.entity().name ?? ""

    required init(context: NSManagedObjectContext? = nil, pm: PersistentManager, logger: Logger? = nil) {
        self.context = context ?? pm.context
        self.pm = pm
        self.logger = logger
    }

    func insert(context: NSManagedObjectContext, model: Message) {
        let entity = CDMessage(context: context)
        entity.update(model)
        let cm = CacheConversationManager(pm: pm, logger: logger)
        if let threadEntity = cm.first(with: model.conversation?.id ?? -1) {
            entity.conversation = threadEntity
        } else {
            let newThraed = CDConversation(context: context)
            newThraed.id = model.conversation?.id as? NSNumber
            entity.conversation = newThraed
        }
    }

    func insert(models: [Message]) {
        insertObjects { [weak self] bgTask in
            models.forEach { model in
                self?.insert(context: bgTask, model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int) -> CDMessage? {
        let req = CDMessage.fetchRequest()
        req.predicate = idPredicate(id: id)
        return try? context.fetch(req).first
    }

    func find(predicate: NSPredicate) -> [CDMessage] {
        let req = CDMessage.fetchRequest()
        req.predicate = predicate
        return (try? context.fetch(req)) ?? []
    }

    func update(model _: Message, entity _: CDMessage) {}

    func update(models _: [Message]) {}

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

    func delete(entity _: CDMessage) {}

    func delete(_ threadId: Int?, _ messageId: Int?) {
        let predicate = predicate(threadId, messageId)
        batchDelete(entityName: entityName, predicate: predicate)
    }

    func delete(_ messageId: Int?) {
        let predicate = idPredicate(id: messageId ?? -1)
        batchDelete(entityName: entityName, predicate: predicate)
    }

    func pin(_ pin: Bool, _ threadId: Int?, _ messageId: Int?) {
        let predicate = predicate(threadId, messageId)
        let propertiesToUpdate = ["pinned": NSNumber(booleanLiteral: pin)]
        update(propertiesToUpdate, predicate)
    }

    func seen(_ request: MessageSeenRequest) {
        let predicate = predicate(request.threadId, request.messageId)
        let propertiesToUpdate = ["seen": NSNumber(booleanLiteral: true)]
        update(propertiesToUpdate, predicate)
    }

    func predicate(_ threadId: Int?, _ messageId: Int?) -> NSPredicate {
        let threadId = threadId ?? -1
        let messageId = messageId ?? -1
        return NSPredicate(format: "conversation.id == %i OR threadId == %i AND id == %i", threadId, threadId, messageId)
    }

    func partnerDeliver(_ response: MessageResponse) {
        let predicate = predicate(response.threadId, response.messageId)
        let propertiesToUpdate = ["delivered": NSNumber(booleanLiteral: true)]
        update(propertiesToUpdate, predicate)
        let cm = CacheConversationManager(pm: pm, logger: logger)
        cm.partnerDeliver(response)
        save()
    }

    func partnerSeen(_ response: MessageResponse) {
        let predicate = predicate(response.threadId, response.messageId)
        let propertiesToUpdate = ["seen": NSNumber(booleanLiteral: true)]
        update(propertiesToUpdate, predicate)
        let cm = CacheConversationManager(pm: pm, logger: logger)
        cm.partnerDeliver(response)
        save()
    }

    func predicateArray(_ req: GetHistoryRequest) -> NSCompoundPredicate {
        var predicateArray = [NSPredicate]()
        predicateArray.append(NSPredicate(format: "conversation.id == %i", req.threadId))
        if let messageId = req.messageId {
            predicateArray.append(NSPredicate(format: "id == %i", messageId))
        }
        if let uniqueIds = req.uniqueIds {
            predicateArray.append(NSPredicate(format: "uniqueId IN %@", uniqueIds))
        }
        if let formTime = req.fromTime as? NSNumber {
            predicateArray.append(NSPredicate(format: "time >= %@", formTime))
        }
        if let toTime = req.toTime as? NSNumber {
            predicateArray.append(NSPredicate(format: "time <= %@", toTime))
        }
        if let query = req.query, query != "" {
            predicateArray.append(NSPredicate(format: "message CONTAINS[cd] %@", query))
        }
        if let messageType = req.messageType {
            predicateArray.append(NSPredicate(format: "messageType == %i", messageType))
        }
        return NSCompoundPredicate(type: .and, subpredicates: predicateArray)
    }

    @discardableResult
    func find(_ threadId: Int?, _ messageId: Int?) -> CDMessage? {
        let req = CDMessage.fetchRequest()
        req.predicate = predicate(threadId, messageId)
        return try? context.fetch(req).first
    }

    func fecthMessage(threadId: Int?, messageId: Int?) -> CDMessage? {
        let req = CDMessage.fetchRequest()
        req.predicate = predicate(threadId, messageId)
        return try? context.fetch(req).first
    }

    func fetch(_ req: GetHistoryRequest) -> (messages: [CDMessage], totalCount: Int) {
        let fetchRequest = CDMessage.fetchRequest()
        fetchRequest.fetchOffset = req.offset
        fetchRequest.fetchLimit = req.count
        let sortByTime = NSSortDescriptor(key: "time", ascending: (req.order == Ordering.asc.rawValue) ? true : false)
        fetchRequest.sortDescriptors = [sortByTime]
        fetchRequest.predicate = predicateArray(req)
        let totalCount = (try? context.count(for: fetchRequest)) ?? 0
        let messages = (try? context.fetch(fetchRequest)) ?? []
        return (messages, totalCount)
    }

    func getMentions(_ req: MentionRequest) -> (objects: [CDMessage], totalCount: Int) {
        let predicate = NSPredicate(format: "conversation.id == %i OR threadId == %i", req.threadId, req.threadId)
        let res: (objects: [CDMessage], totalCount: Int) = fetchWithOffset(count: req.count, offset: req.offset, predicate: predicate)
        return res
    }
}
