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

    func insert(model _: Message) {}

    func updateRelations(_ entity: CDMessage, _ model: Message) {
        entity.threadId = entity.conversation?.id ?? (model.conversation?.id as? NSNumber)
        updateParticipant(entity, model)
        updateForwardInfo(entity, model)
        updateReplyInfo(entity, model)
    }

    func updateParticipant(_ entity: CDMessage, _ model: Message) {
        if let participant = model.participant {
            let req = CDParticipant.fetchRequest()
            req.predicate = NSPredicate(format: "conversation.id == %i AND id == %i", entity.conversation?.id?.intValue ?? -1, participant.id ?? -1)
            var participnatEntity = try? context.fetch(req).first
            if participnatEntity == nil {
                participnatEntity = CDParticipant(context: context)
                participnatEntity?.update(participant)
            }
            entity.participant = participnatEntity
            participnatEntity?.conversation = entity.conversation
        }
    }

    func updateReplyInfo(_ entity: CDMessage, _ model: Message) {
        if let replyInfoModel = model.replyInfo {
            let replyInfoEntity = CDReplyInfo(context: context)
            replyInfoEntity.repliedToMessageId = replyInfoModel.repliedToMessageId as? NSNumber
            replyInfoEntity.participant?.id = model.replyInfo?.participant?.id as? NSNumber
            replyInfoEntity.update(replyInfoModel)
            entity.replyInfo = replyInfoEntity
        }
    }

    func updateForwardInfo(_ entity: CDMessage, _ model: Message) {
        if let forwardInfoModel = model.forwardInfo {
            let forwardInfoEntity = CDForwardInfo(context: context)
            forwardInfoEntity.messageId = model.id as? NSNumber
            forwardInfoEntity.participant = entity.participant

            if let conversation = forwardInfoModel.conversation {
                let req = CDConversation.fetchRequest()
                req.predicate = NSPredicate(format: "id == %i", conversation.id ?? -1)
                var threadEntity = try? context.fetch(req).first
                if threadEntity == nil {
                    threadEntity = CDConversation(context: context)
                    threadEntity?.update(conversation)
                }
                forwardInfoEntity.conversation = threadEntity
            }
            entity.forwardInfo = forwardInfoEntity
        }
    }

    func insertOrUpdateConversation(_ threadModel: Conversation) -> CDConversation? {
        let req = CDConversation.fetchRequest()
        req.predicate = NSPredicate(format: "id == %i", threadModel.id ?? -1)
        var threadEntity = try? context.fetch(req).first
        if threadEntity == nil {
            threadEntity = CDConversation(context: context)
            threadEntity?.update(threadModel)
        }
        return threadEntity
    }

    func insert(models: [Message]) {
        insertObjects(context) { [weak self] _ in
            if let threadModel = models.first?.conversation, let context = self?.context {
                let threadEntity = self?.insertOrUpdateConversation(threadModel)
                models.forEach { model in
                    if model.id == threadEntity?.lastMessageVO?.id?.intValue {
                        threadEntity?.lastMessageVO?.update(model)
                    } else {
                        let entity = CDMessage(context: context)
                        entity.update(model)
                        entity.conversation = threadEntity
                        self?.updateRelations(entity, model)
                    }
                }
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

    /// Set seen only for prior messages where the owner of the message is not me.
    /// We should do that because we need to distinguish between messages that came from the partner or messages sent by myself.
    /// Also we should set delivered to true because when we have seen a message for 100% we have received the message as well.
    /// Also we need to set lastSeenMessageId and time and nano time in the conversation entity to keep it synced.
    func seen(_ request: MessageSeenRequest, userId: Int) {
        let predicate = NSPredicate(format: "threadId == %i AND id <= %i AND (seen = nil OR seen == NO) AND ownerId != %i", request.threadId, request.messageId, userId)
        let propertiesToUpdate = ["seen": NSNumber(booleanLiteral: true), "delivered": NSNumber(booleanLiteral: true)]
        update(propertiesToUpdate, predicate)
        let cmConversation = CacheConversationManager(context: context, logger: logger)
        cmConversation.seen(request)
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
        let threadId = response.threadId ?? -1
        let messageId = response.messageId ?? -1
        let predicate = NSPredicate(format: "threadId == %i AND id <= %i AND (delivered = nil OR delivered == NO)", threadId, messageId)
        let propertiesToUpdate = ["delivered": NSNumber(booleanLiteral: true)]
        update(propertiesToUpdate, predicate)
        let cm = CacheConversationManager(context: context, logger: logger)
        cm.partnerDeliver(response)
    }

    func partnerSeen(_ response: MessageResponse) {
        let threadId = response.threadId ?? -1
        let messageId = response.messageId ?? -1
        let predicate = NSPredicate(format: "threadId == %i AND id <= %i AND (seen = nil OR seen == NO)", threadId, messageId)
        let propertiesToUpdate = ["seen": NSNumber(booleanLiteral: true), "delivered": NSNumber(booleanLiteral: true)]
        update(propertiesToUpdate, predicate)
        let cm = CacheConversationManager(context: context, logger: logger)
        cm.partnerSeen(response)
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
