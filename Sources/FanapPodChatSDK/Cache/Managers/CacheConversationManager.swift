//
//  CacheConversationManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

class CacheConversationManager: CoreDataProtocol {
    let idName = "id"
    let pm: PersistentManager
    var context: NSManagedObjectContext
    let logger: Logger?
    let entityName = CDConversation.entity().name ?? ""

    required init(context: NSManagedObjectContext? = nil, pm: PersistentManager, logger: Logger? = nil) {
        self.context = context ?? pm.context
        self.pm = pm
        self.logger = logger
    }

    func insert(context: NSManagedObjectContext, model: Conversation) {
        let entity = CDConversation(context: context)
        entity.update(model)
        if let lastMessageVO = model.lastMessageVO {
            if let messageEntity = CacheMessageManager(context: context, pm: pm, logger: logger).find(model.id, model.lastMessageVO?.id) {
                entity.lastMessageVO = messageEntity
            } else {
                let newMessageEntity = CDMessage(context: context)
                newMessageEntity.update(lastMessageVO)
                newMessageEntity.conversation = entity
                entity.lastMessageVO = newMessageEntity
            }
        }
    }

    func insert(models: [Conversation]) {
        insertObjects { [weak self] bgTask in
            models.forEach { model in
                self?.insert(context: bgTask, model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int) -> CDConversation? {
        let req = CDConversation.fetchRequest()
        req.predicate = idPredicate(id: id)
        req.fetchLimit = 1
        return try? context.fetch(req).first
    }

    func find(predicate: NSPredicate) -> [CDConversation] {
        let req = CDConversation.fetchRequest()
        req.predicate = predicate
        return (try? context.fetch(req)) ?? []
    }

    func update(model _: Conversation, entity _: CDConversation) {}

    func update(models _: [Conversation]) {}

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

    func delete(entity _: CDConversation) {}

    func seen(_ request: MessageSeenRequest) {
        let predicate = idPredicate(id: request.threadId)
        let propertiesToUpdate = [
            "lastSeenMessageId": (request.messageId) as NSNumber,
            "lastSeenMessageTime": (Date().timeIntervalSince1970) as NSNumber,
            "lastSeenMessageNanos": (Date().timeIntervalSince1970) as NSNumber,
        ]
        update(propertiesToUpdate, predicate)
    }

    func partnerDeliver(_ response: MessageResponse) {
        let predicate = idPredicate(id: response.threadId ?? -1)
        let propertiesToUpdate: [String: Any] = [
            "partnerLastDeliveredMessageTime": response.messageTime ?? 0,
            "partnerLastDeliveredMessageNanos": response.messageTime ?? 0,
            "partnerLastDeliveredMessageId": response.messageId ?? -1,
        ]
        update(propertiesToUpdate, predicate)
    }

    func partnerSeen(_ response: MessageResponse) {
        let predicate = idPredicate(id: response.threadId ?? -1)
        let propertiesToUpdate: [String: Any] = [
            "partnerLastSeenMessageTime": response.messageTime ?? 0,
            "partnerLastSeenMessageNanos": response.messageTime ?? 0,
            "partnerLastSeenMessageId": response.messageId ?? -1,
        ]
        update(propertiesToUpdate, predicate)
    }

    func increamentUnreadCount(_ threadId: Int) {
        if let entity = first(with: threadId) {
            entity.unreadCount = NSNumber(integerLiteral: (entity.unreadCount?.intValue ?? 0) + 1)
        }
        save()
    }

    func fetch(_ req: ThreadsRequest) -> (threads: [CDConversation], count: Int) {
        let fetchRequest = CDConversation.fetchRequest()
        fetchRequest.fetchLimit = req.count
        fetchRequest.fetchOffset = req.offset
        var orFetchPredicatArray = [NSPredicate]()
        if let name = req.name, name != "" {
            let searchTitle = NSPredicate(format: "title CONTAINS[cd] %@", name)
            let searchDescriptions = NSPredicate(format: "descriptions CONTAINS[cd] %@", name)
            orFetchPredicatArray.append(searchTitle)
            orFetchPredicatArray.append(searchDescriptions)
        }

        req.threadIds?.forEach { threadId in
            orFetchPredicatArray.append(NSPredicate(format: "id == %i", threadId))
        }

        let archivePredicate = NSPredicate(format: "isArchive == %@", NSNumber(value: req.archived ?? false))
        orFetchPredicatArray.append(archivePredicate)
        let orCompound = NSCompoundPredicate(type: .or, subpredicates: orFetchPredicatArray)
        fetchRequest.predicate = orCompound

        let sortByTime = NSSortDescriptor(key: "time", ascending: false)
        let sortByPin = NSSortDescriptor(key: "pin", ascending: false)
        fetchRequest.sortDescriptors = [sortByPin, sortByTime]
        let threads = (try? context.fetch(fetchRequest)) ?? []
        fetchRequest.fetchLimit = 0
        fetchRequest.fetchOffset = 0
        let count = (try? context.count(for: fetchRequest)) ?? 0
        return (threads, count)
    }

    func fetchIds() -> [Int] {
        let req = NSFetchRequest<NSDictionary>(entityName: entityName)
        req.resultType = .dictionaryResultType
        req.propertiesToFetch = ["id"]
        let dic = try? context.fetch(req)
        let threadIds = dic?.flatMap(\.allValues).compactMap { $0 as? Int }
        return threadIds ?? []
    }

    func archive(_ archive: Bool, _ threadId: Int?) {
        let predicate = idPredicate(id: threadId ?? -1)
        let propertiesToUpdate: [String: Any] = ["isArchive": NSNumber(booleanLiteral: archive)]
        update(propertiesToUpdate, predicate)
    }

    func close(_ close: Bool, _ threadId: Int?) {
        let predicate = idPredicate(id: threadId ?? -1)
        let propertiesToUpdate: [String: Any] = ["closedThread": NSNumber(booleanLiteral: close)]
        update(propertiesToUpdate, predicate)
    }

    func mute(_ mute: Bool, _ threadId: Int?) {
        let predicate = idPredicate(id: threadId ?? -1)
        let propertiesToUpdate: [String: Any] = ["mute": NSNumber(booleanLiteral: mute)]
        update(propertiesToUpdate, predicate)
    }

    func pin(_ pin: Bool, _ threadId: Int?) {
        let predicate = idPredicate(id: threadId ?? -1)
        let propertiesToUpdate: [String: Any] = ["pin": NSNumber(booleanLiteral: pin)]
        update(propertiesToUpdate, predicate)
    }

    func updateLastMessage(_ thread: Conversation) {
        let entity = first(with: thread.id ?? -1)
        entity?.lastMessage = thread.lastMessage
        if let lastMessageVO = thread.lastMessageVO {
            entity?.lastMessageVO?.update(lastMessageVO)
        }
    }

    func updateLastMessage(_ threadId: Int?, _ text: String) {
        let predicate = idPredicate(id: threadId ?? -1)
        let propertiesToUpdate: [String: Any] = ["lastMessage": text]
        update(propertiesToUpdate, predicate)
    }

    func changeThreadType(_ thread: Conversation?) {
        let predicate = idPredicate(id: thread?.id ?? -1)
        let propertiesToUpdate: [String: Any] = ["type": thread?.type?.rawValue ?? -1]
        update(propertiesToUpdate, predicate)
    }

    func allUnreadCount() -> Int {
        let col = NSExpression(forKeyPath: "unreadCount")
        let exp = NSExpression(forFunction: "sum:", arguments: [col])
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = exp
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .integer64AttributeType
        let req = NSFetchRequest<NSDictionary>(entityName: entityName)
        req.propertiesToFetch = [sumDesc]
        req.returnsObjectsAsFaults = false
        req.resultType = .dictionaryResultType
        let dic = try? context.fetch(req).first as? [String: Int]
        return dic?["sum"] ?? 0
    }

    func delete(_ threadId: Int) {
        let predicate = idPredicate(id: threadId)
        batchDelete(entityName: entityName, predicate: predicate)
    }
}
