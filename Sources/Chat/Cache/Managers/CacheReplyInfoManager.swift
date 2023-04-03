//
//  CacheReplyInfoManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation
import Logger

final class CacheReplyInfoManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger

    required init(context: NSManagedObjectContext, logger: Logger) {
        self.context = context
        self.logger = logger
    }

    func insert(model: ReplyInfo) {
        let entity = CDReplyInfo.insertEntity(context)
        entity.update(model)

        if let participant = model.participant, let thread = model.participant?.conversation {
            CacheConversationManager(context: context, logger: logger).findOrCreateEntity(thread.id) { threadEntity in
                threadEntity?.update(thread)
                CacheParticipantManager(context: self.context, logger: self.logger).findOrCreateEntity(thread.id, participant.id) { participantEntity in
                    participantEntity?.update(participant)
                    participantEntity?.conversation = threadEntity
                    entity.participant = participantEntity
                }
            }
        }
    }

    func insert(models: [ReplyInfo]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int, _ completion: @escaping (CDReplyInfo?) -> Void) {
        context.perform {
            let req = CDReplyInfo.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let reply = try self.context.fetch(req).first
            completion(reply)
        }
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDReplyInfo]) -> Void) {
        context.perform {
            let req = CDReplyInfo.fetchRequest()
            req.predicate = predicate
            let replyes = try self.context.fetch(req)
            completion(replyes)
        }
    }

    func update(model _: ReplyInfo, entity _: CDReplyInfo) {}

    func update(models _: [ReplyInfo]) {}

    func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: CDReplyInfo.entityName)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDReplyInfo) {}

    func first(_ participantId: Int?, _ repliedToMessageId: Int?, _ completion: @escaping (CDReplyInfo?) -> Void) {
        context.perform {
            let predicate = NSPredicate(format: "participant.id == %i AND repliedToMessageId == %i", participantId ?? -1, repliedToMessageId ?? -1)
            let req = CDReplyInfo.fetchRequest()
            req.predicate = predicate
            req.fetchLimit = 1
            let reply = try self.context.fetch(req).first
            completion(reply)
        }
    }

    func findOrCreate(_ participantId: Int?, _ replyToMessageId: Int?, _ completion: @escaping (CDReplyInfo?) -> Void) {
        first(participantId, replyToMessageId) { message in
            completion(message ?? CDReplyInfo.insertEntity(self.context))
        }
    }
}
