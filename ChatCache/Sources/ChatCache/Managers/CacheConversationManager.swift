//
//  CacheConversationManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation
import Logger
import ChatModels
import ChatDTO

public final class CacheConversationManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger

    required init(context: NSManagedObjectContext, logger: Logger) {
        self.context = context
        self.logger = logger
    }

    func insert(model: Conversation) {
        do {
            let req = CDConversation.fetchRequest()
            req.predicate = NSPredicate(format: "id == %i", model.id ?? -1)
            var entity = try context.fetch(req).first
            if entity == nil {
                entity = CDConversation.insertEntity(context)
            }
            entity?.update(model)

            if let lastMessageVO = model.lastMessageVO {
                let req = CDMessage.fetchRequest()
                req.predicate = NSPredicate(format: "conversation.id == %i AND id == %i", model.id ?? -1, lastMessageVO.id ?? -1)
                var messageEntity = try context.fetch(req).first
                if messageEntity == nil {
                    messageEntity = CDMessage.insertEntity(context)
                    messageEntity?.update(lastMessageVO)
                }
                messageEntity?.conversation = entity
                messageEntity?.threadId = model.id as? NSNumber
                entity?.lastMessageVO = messageEntity

                if let participant = model.lastMessageVO?.participant {
                    let participantReq = CDParticipant.fetchRequest()
                    participantReq.predicate = NSPredicate(format: "conversation.id == %i AND id == %i", model.id ?? -1, participant.id ?? -1)
                    var participantEntity = try context.fetch(participantReq).first
                    if participantEntity == nil {
                        participantEntity = CDParticipant.insertEntity(context)
                        participantEntity?.update(participant)
                    }
                    participantEntity?.conversation = entity
                    messageEntity?.participant = participantEntity
                }
            }

            model.pinMessages?.forEach { pinMessage in
                let pinMessageEntity = CDMessage.insertEntity(context)
                pinMessageEntity.update(pinMessage)
                pinMessageEntity.pinned = true
                pinMessageEntity.threadId = entity?.id
                pinMessageEntity.conversation = entity
                entity?.addToPinMessages(pinMessageEntity)
            }
        } catch {
            logger.log(message: error.localizedDescription, persist: true, type: .internalLog)
        }
    }

    public func insert(models: [Conversation]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int, _ completion: @escaping (CDConversation?) -> Void) {
        context.perform {
            let req = CDConversation.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            req.fetchLimit = 1
            let thread = try self.context.fetch(req).first
            completion(thread)
        }
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDConversation]) -> Void) {
        context.perform {
            let req = CDConversation.fetchRequest()
            req.predicate = predicate
            let threads = try self.context.fetch(req)
            completion(threads)
        }
    }

    func update(model _: Conversation, entity _: CDConversation) {}

    func update(models _: [Conversation]) {}

    func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: CDConversation.entityName)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDConversation) {}

    public func seen(_ request: MessageSeenRequest) {
        let predicate = idPredicate(id: request.threadId)
        let propertiesToUpdate = [
            "lastSeenMessageId": (request.messageId) as NSNumber,
            "lastSeenMessageTime": (Date().timeIntervalSince1970) as NSNumber,
            "lastSeenMessageNanos": (Date().timeIntervalSince1970) as NSNumber,
        ]
        update(propertiesToUpdate, predicate)
    }

    public func partnerDeliver(_ response: MessageResponse) {
        let predicate = idPredicate(id: response.threadId ?? -1)
        let propertiesToUpdate: [String: Any] = [
            "partnerLastDeliveredMessageTime": response.messageTime ?? 0,
            "partnerLastDeliveredMessageNanos": response.messageTime ?? 0,
            "partnerLastDeliveredMessageId": response.messageId ?? -1,
        ]
        update(propertiesToUpdate, predicate)
    }

    public func partnerSeen(_ response: MessageResponse) {
        let predicate = idPredicate(id: response.threadId ?? -1)
        let propertiesToUpdate: [String: Any] = [
            "partnerLastSeenMessageTime": response.messageTime ?? 0,
            "partnerLastSeenMessageNanos": response.messageTime ?? 0,
            "partnerLastSeenMessageId": response.messageId ?? -1,
            "partnerLastDeliveredMessageTime": response.messageTime ?? 0,
            "partnerLastDeliveredMessageNanos": response.messageTime ?? 0,
            "partnerLastDeliveredMessageId": response.messageId ?? -1,
        ]
        update(propertiesToUpdate, predicate)
    }

    public func increamentUnreadCount(_ threadId: Int, _ completion: ((Int) -> Void)? = nil) {
        first(with: threadId) { entity in
            let unreadCount = (entity?.unreadCount?.intValue ?? 0) + 1
            self.update(["unreadCount": unreadCount], self.idPredicate(id: threadId))
            completion?(unreadCount)
        }
    }

    public func decreamentUnreadCount(_ threadId: Int, _ completion: ((Int) -> Void)? = nil) {
        first(with: threadId) { entity in
            let dbCount = entity?.unreadCount?.intValue ?? 0
            let decreamentCount = max(0, dbCount - 1)
            self.update(["unreadCount": decreamentCount], self.idPredicate(id: threadId))
            completion?(decreamentCount)
        }
    }

    public func setUnreadCountToZero(_ threadId: Int, _ completion: ((Int) -> Void)? = nil) {
        context.perform {
            self.update(["unreadCount": 0], self.idPredicate(id: threadId))
            completion?(0)
        }
    }

    public func fetch(_ req: ThreadsRequest, _ completion: @escaping ([CDConversation], Int) -> Void) {
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

        if let threadIds = req.threadIds, threadIds.count > 0 {
            orFetchPredicatArray.append(NSPredicate(format: "id IN %@", threadIds))
        }

        if let isGroup = req.isGroup {
            let groupPredicate = NSPredicate(format: "group == %@", NSNumber(value: isGroup))
            orFetchPredicatArray.append(groupPredicate)
        }

        if let type = req.type?.rawValue {
            let thtreadTypePredicate = NSPredicate(format: "type == %i", type)
            orFetchPredicatArray.append(thtreadTypePredicate)
        }

        let archivePredicate = NSPredicate(format: "isArchive == %@", NSNumber(value: req.archived ?? false))
        orFetchPredicatArray.append(archivePredicate)
        let orCompound = NSCompoundPredicate(type: .and, subpredicates: orFetchPredicatArray)
        fetchRequest.predicate = orCompound

        let sortByTime = NSSortDescriptor(key: "time", ascending: false)
        let sortByPin = NSSortDescriptor(key: "pin", ascending: false)
        fetchRequest.sortDescriptors = [sortByPin, sortByTime]
        fetchRequest.relationshipKeyPathsForPrefetching = ["lastMessageVO"]
        context.perform {
            let threads = try self.context.fetch(fetchRequest)
            fetchRequest.fetchLimit = 0
            fetchRequest.fetchOffset = 0
            let count = try self.context.count(for: fetchRequest)
            completion(threads, count)
        }
    }

    public func fetchIds(_ completion: @escaping ([Int]) -> Void) {
        let req = NSFetchRequest<NSDictionary>(entityName: CDConversation.entityName)
        req.resultType = .dictionaryResultType
        req.propertiesToFetch = ["id"]
        context.perform {
            let dic = try? self.context.fetch(req)
            let threadIds = dic?.flatMap(\.allValues).compactMap { $0 as? Int }
            completion(threadIds ?? [])
        }
    }

    public func archive(_ archive: Bool, _ threadId: Int?) {
        let predicate = idPredicate(id: threadId ?? -1)
        let propertiesToUpdate: [String: Any] = ["isArchive": NSNumber(booleanLiteral: archive)]
        update(propertiesToUpdate, predicate)
    }

    public func close(_ close: Bool, _ threadId: Int?) {
        let predicate = idPredicate(id: threadId ?? -1)
        let propertiesToUpdate: [String: Any] = ["closedThread": NSNumber(booleanLiteral: close)]
        update(propertiesToUpdate, predicate)
    }

    public func mute(_ mute: Bool, _ threadId: Int?) {
        let predicate = idPredicate(id: threadId ?? -1)
        let propertiesToUpdate: [String: Any] = ["mute": NSNumber(booleanLiteral: mute)]
        update(propertiesToUpdate, predicate)
    }

    public func pin(_ pin: Bool, _ threadId: Int?) {
        let predicate = idPredicate(id: threadId ?? -1)
        let propertiesToUpdate: [String: Any] = ["pin": NSNumber(booleanLiteral: pin)]
        update(propertiesToUpdate, predicate)
    }

    public func updateLastMessage(_ thread: Conversation) {
        first(with: thread.id ?? -1) { entity in
            entity?.lastMessage = thread.lastMessage
            if let lastMessageVO = thread.lastMessageVO {
                entity?.lastMessageVO?.update(lastMessageVO)
            }
        }
    }

    public func updateLastMessage(_ threadId: Int?, _ text: String) {
        let predicate = idPredicate(id: threadId ?? -1)
        let propertiesToUpdate: [String: Any] = ["lastMessage": text]
        update(propertiesToUpdate, predicate)
    }

    public func setLastMessageVO(_ message: Message) {
        let threadId = message.threadId ?? -1
        let messageId = message.id ?? -1
        let req = CDConversation.fetchRequest()
        req.predicate = idPredicate(id: threadId)
        let messageReq = CDMessage.fetchRequest()
        messageReq.predicate = NSPredicate(format: "conversation.id == %i AND id == %i", threadId, messageId)
        context.perform {
            if let threadEntity = try self.context.fetch(req).first, let messageEntity = try self.context.fetch(messageReq).first {
                threadEntity.lastMessageVO = messageEntity
                threadEntity.lastMessage = messageEntity.message
                messageEntity.message = message.message
                self.save()
            }
        }
    }

    public func changeThreadType(_ thread: Conversation?) {
        let predicate = idPredicate(id: thread?.id ?? -1)
        let propertiesToUpdate: [String: Any] = ["type": thread?.type?.rawValue ?? -1]
        update(propertiesToUpdate, predicate)
    }

    public func allUnreadCount(_ completion: @escaping (Int) -> Void) {
        context.perform {
            let col = NSExpression(forKeyPath: "unreadCount")
            let exp = NSExpression(forFunction: "sum:", arguments: [col])
            let sumDesc = NSExpressionDescription()
            sumDesc.expression = exp
            sumDesc.name = "sum"
            sumDesc.expressionResultType = .integer64AttributeType
            let req = NSFetchRequest<NSDictionary>(entityName: CDConversation.entityName)
            req.propertiesToFetch = [sumDesc]
            req.returnsObjectsAsFaults = false
            req.resultType = .dictionaryResultType
            let dic = try self.context.fetch(req).first as? [String: Int]
            let allUnreadCount = dic?["sum"] ?? 0
            completion(allUnreadCount)
        }
    }

    public func delete(_ threadId: Int) {
        let predicate = idPredicate(id: threadId)
        batchDelete(context, entityName: CDConversation.entityName, predicate: predicate)
    }

    public func updateThreadsUnreadCount(_ resp: [String: Int]) {
        resp.forEach { key, value in
            let predicate = idPredicate(id: Int(key) ?? -1)
            update(["unreadCount": value], predicate)
        }
    }

    public func threadsUnreadcount(_ threadIds: [Int], _ completion: @escaping ([String: Int]) -> Void) {
        let req = NSFetchRequest<NSDictionary>(entityName: CDConversation.entityName)
        req.resultType = .dictionaryResultType
        req.propertiesToFetch = ["id", "unreadCount"]
        req.predicate = NSPredicate(format: "id IN %@", threadIds)
        context.perform {
            let rows = try? self.context.fetch(req)
            var result: [String: Int] = [:]
            rows?.forEach { dic in
                var threadId = 0
                var unreadCount = 0
                dic.forEach { key, value in
                    if key as? String == "id" {
                        threadId = value as? Int ?? 0
                    } else if key as? String == "unreadCount" {
                        unreadCount = value as? Int ?? 0
                    }
                }
                result[String(threadId)] = unreadCount
            }
            completion(result)
        }
    }

    func findOrCreateEntity(_ threadId: Int?, _ completion: @escaping (CDConversation?) -> Void) {
        first(with: threadId ?? -1) { thread in
            completion(thread ?? CDConversation.insertEntity(self.context))
        }
    }
}
