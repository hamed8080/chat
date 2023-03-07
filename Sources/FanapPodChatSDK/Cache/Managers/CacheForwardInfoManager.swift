//
//  CacheForwardInfoManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

class CacheForwardInfoManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger?

    required init(context: NSManagedObjectContext, logger: Logger? = nil) {
        self.context = context
        self.logger = logger
    }

    func insert(model: ForwardInfo) {
        let entity = CDForwardInfo.insertEntity(context)
        if let participant = model.participant, let thread = model.conversation {
            CacheConversationManager(context: context, logger: logger).findOrCreateEntity(model.conversation?.id) { threadEntity in
                threadEntity?.update(thread)
                CacheParticipantManager(context: self.context, logger: self.logger).findOrCreateEntity(model.conversation?.id, participant.id) { participantEntity in
                    participantEntity?.update(participant)
                    participantEntity?.conversation = threadEntity
                    entity.participant = participantEntity
                }
            }
        }
    }

    func insert(models: [ForwardInfo]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int, _ completion: @escaping (CDForwardInfo?) -> Void) {
        context.perform {
            let req = CDForwardInfo.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let forward = try self.context.fetch(req).first
            completion(forward)
        }
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDForwardInfo]) -> Void) {
        context.perform {
            let req = CDForwardInfo.fetchRequest()
            req.predicate = predicate
            let forwards = try self.context.fetch(req)
            completion(forwards)
        }
    }

    func update(model _: ForwardInfo, entity _: CDForwardInfo) {}

    func update(models _: [ForwardInfo]) {}

    func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: CDForwardInfo.entityName)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDForwardInfo) {}

    func first(_ messageId: Int?, _ threadId: Int?, _: Int?) throws -> CDForwardInfo? {
        let predicate = NSPredicate(format: "message.id == %i AND conversation.id == %i AND participant.id", messageId ?? -1, threadId ?? -1, threadId ?? -1)
        let req = CDForwardInfo.fetchRequest()
        req.predicate = predicate
        req.fetchLimit = 1
        return try context.fetch(req).first
    }
}
