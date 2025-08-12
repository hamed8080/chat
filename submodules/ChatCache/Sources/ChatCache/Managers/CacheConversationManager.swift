//
// CacheConversationManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheConversationManager: BaseCoreDataManager<CDConversation>, @unchecked Sendable {

    /// It will update, the last message seen when the owner of the message is not me I just saw the partner message.
    public func seen(_ seen: CacheLastSeenMessageResponse) {
        let predicate = idPredicate(id: seen.threadId.nsValue)
        let date = Date()
        let propertiesToUpdate = [
            "lastSeenMessageId": (seen.lastSeenMessageId) as NSNumber,
            "lastSeenMessageTime": (seen.lastSeenMessageTime ?? UInt(date.timeIntervalSince1970)) as NSNumber,
            "lastSeenMessageNanos": (seen.lastSeenMessageNanos ?? UInt(date.timeIntervalSince1970)) as NSNumber,
        ]
        update(propertiesToUpdate, predicate)
    }

    /// It will update, the last message has been delivered to the partner.
    public func partnerDeliver(threadId: Int, messageId: Int, messageTime: UInt) {
        let predicate = idPredicate(id: threadId.nsValue)
        let propertiesToUpdate: [String: Any] = [
            "partnerLastDeliveredMessageTime": messageTime,
            "partnerLastDeliveredMessageNanos": messageTime,
            "partnerLastDeliveredMessageId": messageId,
        ]
        update(propertiesToUpdate, predicate)
    }

    /// It will update the last message seen by the partner.
    public func partnerSeen(threadId: Int, messageId: Int, messageTime: UInt = 0) {
        let predicate = idPredicate(id: threadId.nsValue)
        let propertiesToUpdate: [String: Any] = [
            "partnerLastSeenMessageTime": messageTime,
            "partnerLastSeenMessageNanos": messageTime,
            "partnerLastSeenMessageId": messageId,
            "partnerLastDeliveredMessageTime": messageTime,
            "partnerLastDeliveredMessageNanos": messageTime,
            "partnerLastDeliveredMessageId": messageId,
        ]
        update(propertiesToUpdate, predicate)
    }
    
    @MainActor
    public func setUnreadCount(action: CacheUnreadCountAction, threadId: Int) -> Int? {
        guard let entity = self.first(with: threadId.nsValue) else { return nil }
        var cachedThreadCount = entity.unreadCount?.intValue ?? 0
        switch action {
        case .increase:
            cachedThreadCount += 1
            break
        case .decrease:
            cachedThreadCount = max(0, cachedThreadCount - 1)
            break
        case let .set(count):
            cachedThreadCount = max(0, count)
            break
        }
        self.update(["unreadCount": cachedThreadCount], self.idPredicate(id: threadId.nsValue))
        return cachedThreadCount
    }

    @MainActor
    public func fetch(_ req: FetchThreadRequest) -> ([Entity], Int) {
        let fetchRequest = Entity.fetchRequest()
        fetchRequest.fetchLimit = req.count
        fetchRequest.fetchOffset = req.offset
        var orFetchPredicatArray = [NSPredicate]()
        if let title = req.title, title != "" {
            let searchTitle = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(CDConversation.title), title)
            orFetchPredicatArray.append(searchTitle)
        }
        
        if let desc = req.description {
            let searchDescriptions = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(CDConversation.descriptions) , desc)
            orFetchPredicatArray.append(searchDescriptions)
        }
        
        if let threadIds = req.threadIds, threadIds.count > 0 {
            let nsNumbers = threadIds.compactMap({ $0.nsValue })
            orFetchPredicatArray.append(NSPredicate(format: "%K IN %@", #keyPath(CDConversation.id), nsNumbers))
        }
        
        if let isGroup = req.isGroup {
            let groupPredicate = NSPredicate(format: "%K == %@", #keyPath(CDConversation.group), NSNumber(value: isGroup))
            orFetchPredicatArray.append(groupPredicate)
        }
        
        if let type = req.type {
            let thtreadTypePredicate = NSPredicate(format: "%K == %i", #keyPath(CDConversation.type), type)
            orFetchPredicatArray.append(thtreadTypePredicate)
        }
        
        if let archived = req.archived {
            let keyPath = #keyPath(CDConversation.isArchive)
            let archivePredicate = NSPredicate(format: "%K == %@ OR %K == %@", keyPath, NSNumber(value: archived), keyPath, NSNull())
            orFetchPredicatArray.append(archivePredicate)
        }
        let orCompound = NSCompoundPredicate(type: .and, subpredicates: orFetchPredicatArray)
        fetchRequest.predicate = orCompound
        
        let sortByTime = NSSortDescriptor(key: "time", ascending: false)
        let sortByPin = NSSortDescriptor(key: "pin", ascending: false)
        fetchRequest.sortDescriptors = [sortByPin, sortByTime]
        fetchRequest.relationshipKeyPathsForPrefetching = ["lastMessageVO"]
        let threads = (try? self.viewContext.fetch(fetchRequest)) ?? []
        fetchRequest.fetchLimit = 0
        fetchRequest.fetchOffset = 0
        let count = (try? self.viewContext.count(for: fetchRequest)) ?? 0
        return (threads, count)
    }

    @MainActor
    public func fetchIds() -> [Int] {
        let req = NSFetchRequest<NSDictionary>(entityName: Entity.name)
        req.resultType = .dictionaryResultType
        req.propertiesToFetch = [Entity.idName]
        let dic = try? self.viewContext.fetch(req)
        let threadIds = dic?.flatMap(\.allValues).compactMap { $0 as? Int }
        return threadIds ?? []
    }

    public func archive(_ archive: Bool, _ threadId: Int) {
        let predicate = idPredicate(id: threadId.nsValue )
        let propertiesToUpdate: [String: Any] = ["isArchive": NSNumber(booleanLiteral: archive)]
        update(propertiesToUpdate, predicate)
    }

    public func close(_ close: Bool, _ threadId: Int) {
        let predicate = idPredicate(id: threadId.nsValue)
        let propertiesToUpdate: [String: Any] = ["closedThread": NSNumber(booleanLiteral: close)]
        update(propertiesToUpdate, predicate)
    }

    public func mute(_ mute: Bool, _ threadId: Int) {
        let predicate = idPredicate(id: threadId.nsValue)
        let propertiesToUpdate: [String: Any] = ["mute": NSNumber(booleanLiteral: mute)]
        update(propertiesToUpdate, predicate)
    }

    public func pin(_ pin: Bool, _ threadId: Int) {
        let predicate = idPredicate(id: threadId.nsValue)
        let propertiesToUpdate: [String: Any] = ["pin": NSNumber(booleanLiteral: pin)]
        update(propertiesToUpdate, predicate)
    }


    /// Insert if there is no conversation or message object, and update if there is a message or thread entity. and save it immediately.
    @MainActor
    public func replaceLastMessage(_ model: Entity.Model) throws {
        try? replaceLastMessage(model, viewContext)
        save(context: viewContext)
    }

    /// Insert if there is no conversation or message object, and update if there is a message or thread entity.
    /// It will not save anything by itself. Only the parent task should call save whenever you feel it is enough to save context.
    @MainActor
    public func replaceLastMessage(_ model: Entity.Model, _ context: CacheManagedContext) throws {
        guard let threadId = model.id, let lastMessageVO = model.lastMessageVO
        else { throw NSError(domain: "The threadId or LastMessageVO is nil.", code: 0) }
        if let entity = first(with: threadId.nsValue) {
            self.updateLastMessage(entity, threadId, lastMessageVO.toMessage, context)
        } else {
            self.insert(models: [model])
        }
    }

    /// We use uniqueId of message to get a message if it the sender were me and if so, in sendMessage method we have added an entity inside message table without an 'Message.id'
    /// and it will lead to problem such as dupicate message row.
    private func updateLastMessage(_ entity: CDConversation, _ threadId: Int, _ lastMessageVO: Message, _ context: CacheManagedContext) {
        entity.lastMessage = lastMessageVO.message
        entity.lastSeenMessageTime = lastMessageVO.time as? NSNumber
        entity.lastSeenMessageNanos = lastMessageVO.timeNanos as? NSNumber
        entity.lastSeenMessageId = lastMessageVO.id as? NSNumber
        let messageReq = CDMessage.fetchRequest()
        messageReq.predicate = NSPredicate(format: "%K == %@ OR %K == %@", #keyPath(CDMessage.id), (lastMessageVO.id ?? -1).nsValue, #keyPath(CDMessage.uniqueId), lastMessageVO.uniqueId ?? "")
        if let messageEntity = try? context.fetch(messageReq).first {
            messageEntity.update(lastMessageVO)
            messageEntity.conversationLastMessageVO = entity
            entity.lastMessageVO = messageEntity
        } else {
            let insertMessageEntity = CDMessage.insertEntity(context)
            insertMessageEntity.update(lastMessageVO)
            insertMessageEntity.conversation = entity
            entity.lastMessageVO = insertMessageEntity
            let cmParticipant = CacheParticipantManager(container: container, logger: logger)
            cmParticipant.attach(messageEntity: insertMessageEntity, threadEntity: entity, lastMessageVO: lastMessageVO, threadId: threadId, context: context)
        }
    }

    public func changeThreadType(_ threadId: Int, _ type: ThreadTypes) {
        let predicate = idPredicate(id: threadId.nsValue)
        let propertiesToUpdate: [String: Any] = ["type": type.rawValue]
        update(propertiesToUpdate, predicate)
    }

    @MainActor
    public func allUnreadCount() -> Int {
        let col = NSExpression(forKeyPath: "unreadCount")
        let exp = NSExpression(forFunction: "sum:", arguments: [col])
        let sumDesc = NSExpressionDescription()
        sumDesc.expression = exp
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .integer64AttributeType
        let req = NSFetchRequest<NSDictionary>(entityName: Entity.name)
        req.propertiesToFetch = [sumDesc]
        req.returnsObjectsAsFaults = false
        req.resultType = .dictionaryResultType
        let dic = try? viewContext.fetch(req).first as? [String: Int]
        let sum = dic?["sum"]
        return sum ?? 0
    }

    @MainActor
    public func updateThreadsUnreadCount(_ resp: [String: Int]) {
        for (key, value) in resp {
            if let threadId = Int(key) {
                _ = setUnreadCount(action: .set(value), threadId: threadId)
            }
        }
    }

    @MainActor
    public func threadsUnreadcount(_ threadIds: [Int]) -> [String: Int] {
        let req = NSFetchRequest<NSDictionary>(entityName: Entity.name)
        req.resultType = .dictionaryResultType
        req.propertiesToFetch = ["id", "unreadCount"]
        let nsNumbers = threadIds.compactMap{ $0.nsValue }
        req.predicate = NSPredicate(format: "\(Entity.idName) IN %@", nsNumbers)
        let rows = (try? self.viewContext.fetch(req)) ?? []
        let dictionary: [(String, Int)] = rows.compactMap { dic in
            guard let threadId = dic[Entity.idName] as? Int, let unreadCount = dic["unreadCount"] as? Int else { return nil }
            return (String(threadId), unreadCount)
        }
        let result = dictionary.reduce(into: [:]) { $0[$1.0] = $1.1 }
        return result
    }

    @MainActor
    public func conversationsPin(_ dictionary: [Int: PinMessage]) {
        dictionary.forEach { (key, value) in
            let entity = Entity.findOrCreate(threadId: key, context: self.viewContext)
            entity.id = key as NSNumber
            entity.pinMessage = value.toClass
        }
        saveViewContext()
    }

    @MainActor
    public func updateTitle(id: Int, title: String?) {
        let req = Entity.fetchRequest()
        req.predicate = idPredicate(id: id.nsValue)
        req.fetchLimit = 1
        if let cdConv = try? self.viewContext.fetch(req).first {
            cdConv.title = title
            self.saveViewContext()
        }
    }
}
