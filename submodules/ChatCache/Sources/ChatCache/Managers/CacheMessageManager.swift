//
// CacheMessageManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheMessageManager: BaseCoreDataManager<CDMessage>, @unchecked Sendable {
    
    /// This method prevents excess query to Store and SQLite as a result of only fetching conversation one time.
    /// We must fetch the message object with findOrCreate, if not it will lead to lastMessageVO object corruption.
    public func insert(models: [Message], threadId: Int) {
        insertObjects { context in
            let threadEntity: CDConversation = CDConversation.findOrCreate(threadId: threadId, context: context)
            models.forEach { model in
                if let messageId = model.id {
                    let entity: CDMessage = self.findOrCreate(messageId.nsValue, context)
                    entity.update(model)
                    entity.conversation = threadEntity
                }
            }
        }
    }
    
    public func delete(_ threadId: Int, _ messageId: Int) {
        let predicate = predicate(threadId, messageId)
        let req = Entity.fetchRequest()
        req.predicate = predicate
        guard let message = (try? viewContext.fetch(req))?.first else { return }
        if let next = next(threadId: threadId, messageId: messageId) {
            next.previousId = message.previousId
        }
        viewContext.delete(message)
        saveViewContext()
    }
    
    public func pin(_ pin: Bool, _ threadId: Int, _ messageId: Int) {
        let predicate = predicate(threadId, messageId)
        let propertiesToUpdate = ["pinned": NSNumber(booleanLiteral: pin)]
        update(propertiesToUpdate, predicate)
    }
    
    public func addOrRemoveThreadPinMessages(_ pin: Bool, _ threadId: Int, _ messageId: Int) {
        let req = CDConversation.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", threadId.nsValue)
        guard let threadEntity = try? viewContext.fetch(req).first else { return }
        if pin == false {
            threadEntity.pinMessage = nil
            saveViewContext()
        }
        
        if pin == true {
            let messageReq = Entity.fetchRequest()
            messageReq.predicate = predicate(threadId, messageId)
            if let entity = try? viewContext.fetch(messageReq).first {
                threadEntity.pinMessage = PinMessageClass(message: entity.codable())
                saveViewContext()
            }
        }
    }
    
    /// The owner of the message is our partner so we just seen it.
    /// Set seen only for prior messages where the owner of the message is not me.
    /// We should do that because we need to distinguish between messages that came from the partner or messages sent by myself.
    /// Also we should set delivered to true because when we have seen a message for 100% we have received the message as well.
    /// Also we need to set lastSeenMessageId and time and nano time in the conversation entity to keep it synced.
    public func seen(threadId: Int, messageId: Int, mineUserId: Int) {
        let predicate = NSPredicate(format: "threadId == %@ AND \(Entity.idName) <= \(Entity.queryIdSpecifier) AND (seen = nil OR seen == NO) AND ownerId != %@", threadId.nsValue, messageId.nsValue, mineUserId.nsValue)
        let propertiesToUpdate = ["seen": NSNumber(booleanLiteral: true), "delivered": NSNumber(booleanLiteral: true)]
        update(propertiesToUpdate, predicate)
        let cmConversation = CacheConversationManager(container: container, logger: logger)
        cmConversation.seen(threadId: threadId, lastSeenMessageId: messageId)
    }
    
    /// We don't join with the conversation.id because it leads to a crash when batch updating due to lack of relation update query support in a predicate in batch mode.
    public func predicate(_ threadId: Int, _ messageId: Int) -> NSPredicate {
        return NSPredicate(format: "threadId == \(CDConversation.queryIdSpecifier) AND \(Entity.idName) == \(Entity.queryIdSpecifier)", threadId.nsValue, messageId.nsValue)
    }
    
    public func joinPredicate(_ threadId: NSNumber, _ messageId: NSNumber) -> NSPredicate {
        return NSPredicate(format: "(conversation.id == \(CDConversation.queryIdSpecifier) OR threadId == \(CDConversation.queryIdSpecifier)) AND \(Entity.idName) == \(Entity.queryIdSpecifier)", threadId, threadId, messageId)
    }
    
    public func partnerDeliver(threadId: Int, messageId: Int, messageTime: UInt = 0) {
        let predicate = NSPredicate(format: "threadId == \(CDConversation.queryIdSpecifier) AND \(Entity.idName) <= \(Entity.queryIdSpecifier) AND (delivered = nil OR delivered == NO)", threadId.nsValue, messageId.nsValue)
        let propertiesToUpdate = ["delivered": NSNumber(booleanLiteral: true)]
        update(propertiesToUpdate, predicate)
        let cm = CacheConversationManager(container: container, logger: logger)
        cm.partnerDeliver(threadId: threadId, messageId: messageId, messageTime: messageTime)
    }
    
    /// The owner of the message is us so all prior messages will be seen for our partner if they see last message.
    /// We must update all entities rows where all seen are nil or false
    /// As well as cheking the owner is mine.
    public func partnerSeen(threadId: Int, messageId: Int, mineUserId: Int) {
        let predicate = NSPredicate(format: "threadId == \(CDConversation.queryIdSpecifier) AND \(Entity.idName) <= \(Entity.queryIdSpecifier) AND (seen = nil OR seen == NO) AND ownerId == %@", threadId.nsValue, messageId.nsValue, mineUserId.nsValue)
        let propertiesToUpdate = ["seen": NSNumber(booleanLiteral: true), "delivered": NSNumber(booleanLiteral: true)]
        update(propertiesToUpdate, predicate)
        let cm = CacheConversationManager(container: container, logger: logger)
        cm.partnerSeen(threadId: threadId, messageId: messageId)
    }
    
    public func predicateArray(_ req: FetchMessagesRequest) -> NSCompoundPredicate {
        var predicateArray = [NSPredicate]()
        predicateArray.append(NSPredicate(format: "threadId == \(CDConversation.queryIdSpecifier)", req.threadId))
        if let messageId = req.messageId {
            predicateArray.append(NSPredicate(format: "\(Entity.idName) == \(Entity.queryIdSpecifier)", messageId))
        }
        if let uniqueIds = req.uniqueIds {
            predicateArray.append(NSPredicate(format: "uniqueId IN %@", uniqueIds))
        }
        if let formTime = req.fromTime {
            predicateArray.append(NSPredicate(format: "time >= %@", formTime))
        }
        if let toTime = req.toTime {
            predicateArray.append(NSPredicate(format: "time < %@", toTime))
        }
        if let query = req.query, query != "" {
            predicateArray.append(NSPredicate(format: "message CONTAINS[cd] %@", query))
        }
        if let messageType = req.messageType {
            predicateArray.append(NSPredicate(format: "messageType == %i", messageType))
        }
        return NSCompoundPredicate(type: .and, subpredicates: predicateArray)
    }
    
    public func find(_ threadId: Int, _ messageId: Int, _ completion: @escaping @Sendable (Entity?) -> Void) {
        viewContext.perform {
            let req = Entity.fetchRequest()
            req.predicate = self.joinPredicate(threadId.nsValue, messageId.nsValue)
            let message = try self.viewContext.fetch(req).first
            completion(message)
        }
    }
    
    public func find(_ threadId: Int, _ messageId: Int) async -> Entity.Model? {
        typealias ResultType = CheckedContinuation<Entity.Model?, Never>
        return await withCheckedContinuation { (continuation: ResultType) in
            find(threadId, messageId) { entity in
                continuation.resume(with: .success(entity?.codable()))
            }
        }
    }
    
    public func deleteAndReduceUnreadCountIfNeeded(_ threadId: Int, _ messageId: Int, _ userId: Int) async {
        if let entity = await find(threadId, messageId) {
            if entity.ownerId != userId, entity.seen == nil {
                let cm = CacheConversationManager(container: container, logger: logger)
                cm.setUnreadCount(action: .decrease, threadId: threadId)
            }
            delete(threadId, messageId)
        }
    }

    public func fetch(_ req: FetchMessagesRequest, _ completion: @escaping @Sendable ([Entity], Int) -> Void) {
        viewContext.perform {
            let fetchRequest = Entity.fetchRequest()
            let asc = (req.order == Ordering.asc.rawValue) ? true : false
            let sortByTime = NSSortDescriptor(key: "time", ascending: asc)
            fetchRequest.sortDescriptors = [sortByTime]
            fetchRequest.predicate = self.predicateArray(req)
            let totalCount = try self.viewContext.count(for: fetchRequest)
            fetchRequest.fetchOffset = req.offset
            fetchRequest.fetchLimit = req.count
            let messages = try self.viewContext.fetch(fetchRequest).sorted(by: { self.compare(asc, $0, $1) })
            completion(messages, totalCount)
        }
    }

    private func compare(_ ascending: Bool, _ message1: CDMessage, _ message2: CDMessage) -> Bool {
        if let time1 = message1.time?.intValue, let time2 = message2.time?.intValue {
            if ascending {
                return time1 > time2
            } else {
                return time1 < time2
            }
        } else {
            return false
        }
    }

    public func getMentions(threadId: Int, offset: Int = 0, count: Int = 25, _ completion: @escaping @Sendable ([Entity], Int) -> Void) {
        let predicate = NSPredicate(format: "threadId == \(CDConversation.queryIdSpecifier) AND mentioned == YES", threadId.nsValue)
        let sPredicate = SendableNSPredicate(predicate: predicate)
        fetchWithOffset(count: count, offset: offset, predicate: sPredicate, completion)
    }

    public func clearHistory(threadId: Int) {
        let predicate = NSPredicate(format: "threadId == \(CDConversation.queryIdSpecifier)", threadId.nsValue)
        batchDelete(predicate: predicate)
    }

    public func next(threadId: Int, messageId: Int) -> Entity? {
        let predicate = NSPredicate(format: "id > %@ && threadId == %@", messageId.nsValue, threadId.nsValue)
        let req = Entity.fetchRequest()
        req.predicate = predicate
        req.fetchLimit = 1
        req.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        guard let message = (try? viewContext.fetch(req))?.first else { return nil }
        return message
    }

    public func isContains(time: UInt, threadId: Int) -> Bool {
        let predicate = NSPredicate(format: "time == %@ && threadId == %@", Int(time).nsValue, threadId.nsValue)
        let req = Entity.fetchRequest()
        req.predicate = predicate
        req.fetchLimit = 1
        let result = try? viewContext.fetch(req)
        return result?.count == 1
    }
}
