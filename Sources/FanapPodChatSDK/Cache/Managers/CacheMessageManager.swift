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
    var context: NSManagedObjectContext
    let logger: Logger?
    let entityName = CDMessage.entity().name ?? "CDMessage"

    required init(context: NSManagedObjectContext, logger: Logger? = nil) {
        self.context = context
        self.logger = logger
    }

    func insert(model: Message) {
        let entity = CDMessage(context: context)
        entity.update(model)
        updateRelations(entity, model)
    }

    func updateRelations(_ entity: CDMessage, _ model: Message) {
        updateConversation(entity, model)
        entity.threadId = entity.conversation?.id ?? (model.conversation?.id as? NSNumber)
        updateForwardInfo(entity, model)
        updateParticipant(entity, model)
        updateReplyInfo(entity, model)
    }

    func updateParticipant(_ entity: CDMessage, _ model: Message) {
        if let participant = model.participant {
            CacheParticipantManager(context: context, logger: logger).findOrCreateEntity(model.conversation?.id, participant.id) { participantEntity in
                participantEntity?.update(participant)
                participantEntity?.conversation = entity.conversation
                entity.participant = participantEntity
            }
        }
    }

    func updateReplyInfo(_ entity: CDMessage, _ model: Message) {
        if let replyInfo = model.replyInfo {
            CacheReplyInfoManager(context: context, logger: logger).findOrCreate(replyInfo.participant?.id, replyInfo.repliedToMessageId) { repltInfoEntity in
                repltInfoEntity?.update(replyInfo)
                entity.replyInfo = repltInfoEntity
            }
        }
    }

    func updateForwardInfo(_ entity: CDMessage, _ model: Message) {
        if let forwardInfo = model.forwardInfo {
            let cmForward = CacheForwardInfoManager(context: context, logger: logger)
            cmForward.insert(forwardInfo, entity)
        }
    }

    func updateConversation(_ entity: CDMessage, _ model: Message) {
        if let conversation = model.conversation {
            CacheConversationManager(context: context, logger: logger).findOrCreateEntity(conversation.id) { threadEntity in
                threadEntity?.id = conversation.id as? NSNumber
                entity.conversation = threadEntity
            }
        }
    }

    func insert(models: [Message]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int, _ completion: @escaping (CDMessage?) -> Void) {
        context.perform {
            let req = CDMessage.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let message = try? self.context.fetch(req).first
            completion(message)
        }
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDMessage]) -> Void) {
        context.perform {
            let req = CDMessage.fetchRequest()
            req.predicate = predicate
            let messages = (try? self.context.fetch(req)) ?? []
            completion(messages)
        }
    }

    func update(model _: Message, entity _: CDMessage) {}

    func update(models _: [Message]) {}

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

    func delete(entity _: CDMessage) {}

    func delete(_ threadId: Int?, _ messageId: Int?) {
        let predicate = predicate(threadId, messageId)
        batchDelete(context, entityName: entityName, predicate: predicate)
    }

    func delete(_ messageId: Int?) {
        let predicate = idPredicate(id: messageId ?? -1)
        batchDelete(context, entityName: entityName, predicate: predicate)
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

    // We don't join with the conversation.id because it leads to a crash when batch updating due to lack of relation update query support in a predicate in batch mode.
    func predicate(_ threadId: Int?, _ messageId: Int?) -> NSPredicate {
        let threadId = threadId ?? -1
        let messageId = messageId ?? -1
        return NSPredicate(format: "threadId == %i AND id == %i", threadId, messageId)
    }

    func joinPredicate(_ threadId: Int?, _ messageId: Int?) -> NSPredicate {
        let threadId = threadId ?? -1
        let messageId = messageId ?? -1
        return NSPredicate(format: "(conversation.id == %i OR threadId == %i) AND id == %i", threadId, threadId, messageId)
    }

    func partnerDeliver(_ response: MessageResponse) {
        let predicate = predicate(response.threadId, response.messageId)
        let propertiesToUpdate = ["delivered": NSNumber(booleanLiteral: true)]
        update(propertiesToUpdate, predicate)
        let cm = CacheConversationManager(context: context, logger: logger)
        cm.partnerDeliver(response)
        save()
    }

    func partnerSeen(_ response: MessageResponse) {
        let predicate = predicate(response.threadId, response.messageId)
        let propertiesToUpdate = ["seen": NSNumber(booleanLiteral: true)]
        update(propertiesToUpdate, predicate)
        let cm = CacheConversationManager(context: context, logger: logger)
        cm.partnerDeliver(response)
        save()
    }

    func predicateArray(_ req: GetHistoryRequest) -> NSCompoundPredicate {
        var predicateArray = [NSPredicate]()
        predicateArray.append(NSPredicate(format: "threadId == %i", req.threadId))
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

    func find(_ threadId: Int?, _ messageId: Int?, _ completion: @escaping (CDMessage?) -> Void) {
        context.perform {
            let req = CDMessage.fetchRequest()
            req.predicate = self.joinPredicate(threadId, messageId)
            let message = try? self.context.fetch(req).first
            completion(message)
        }
    }

    func fecthMessage(threadId: Int?, messageId: Int?) -> CDMessage? {
        let req = CDMessage.fetchRequest()
        req.predicate = predicate(threadId, messageId)
        return try? context.fetch(req).first
    }

    func fetch(_ req: GetHistoryRequest, _ completion: @escaping ([CDMessage], Int) -> Void) {
        context.perform {
            let fetchRequest = CDMessage.fetchRequest()
            let sortByTime = NSSortDescriptor(key: "time", ascending: (req.order == Ordering.asc.rawValue) ? true : false)
            fetchRequest.sortDescriptors = [sortByTime]
            fetchRequest.predicate = self.predicateArray(req)
            let totalCount = (try? self.context.count(for: fetchRequest)) ?? 0
            fetchRequest.fetchOffset = req.offset
            fetchRequest.fetchLimit = req.count
            let messages = (try? self.context.fetch(fetchRequest)) ?? []
            completion(messages, totalCount)
        }
    }

    func getMentions(_ req: MentionRequest, _ completion: @escaping ([CDMessage], Int) -> Void) {
        let predicate = NSPredicate(format: "threadId == %i", req.threadId, req.threadId)
        fetchWithOffset(count: req.count, offset: req.offset, predicate: predicate, completion)
    }

    func clearHistory(threadId: Int?) {
        let predicate = NSPredicate(format: "threadId == %i", threadId ?? -1)
        batchDelete(context, entityName: entityName, predicate: predicate)
    }

    func findOrCreate(_ threadId: Int?, _ messageId: Int?, _ completion: @escaping (CDMessage?) -> Void) {
        find(threadId, messageId) { message in
            completion(message ?? CDMessage(context: self.context))
        }
    }
}
