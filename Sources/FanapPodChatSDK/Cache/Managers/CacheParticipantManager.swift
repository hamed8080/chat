//
//  CacheParticipantManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

final class CacheParticipantManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger?

    required init(context: NSManagedObjectContext, logger: Logger? = nil) {
        self.context = context
        self.logger = logger
    }

    func insert(model: Participant) {
        let entity = CDParticipant.insertEntity(context)
        entity.update(model)
        CacheConversationManager(context: context, logger: logger).findOrCreateEntity(model.conversation?.id ?? -1) { threadEntity in
            threadEntity?.addToParticipants(entity)
        }
    }

    func insert(models: [Participant]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func insert(model: Conversation?) {
        CacheConversationManager(context: context, logger: logger).findOrCreateEntity(model?.id ?? -1) { threadEntity in
            self.insertObjects(self.context) { _ in
                if let threadEntity = threadEntity {
                    model?.participants?.forEach { participant in
                        let participantEntity = CDParticipant.insertEntity(self.context)
                        participantEntity.update(participant)
                        threadEntity.addToParticipants(participantEntity)
                    }
                }
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int, _ completion: @escaping (CDParticipant?) -> Void) {
        context.perform {
            let req = CDParticipant.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let participant = try self.context.fetch(req).first
            completion(participant)
        }
    }

    func first(_ threadId: Int, _ participantId: Int, _ completion: @escaping (CDParticipant?) -> Void) {
        context.perform {
            let req = CDParticipant.fetchRequest()
            req.predicate = self.predicate(threadId, participantId)
            let participant = try self.context.fetch(req).first
            completion(participant)
        }
    }

    func predicate(_ threadId: Int, _ participantId: Int) -> NSPredicate {
        NSPredicate(format: "conversation.id == %i AND id == %i", threadId, threadId, participantId)
    }

    func find(predicate: NSPredicate, _ completion: @escaping ([CDParticipant]) -> Void) {
        context.perform {
            let req = CDParticipant.fetchRequest()
            req.predicate = predicate
            let participants = try self.context.fetch(req)
            completion(participants)
        }
    }

    func update(model _: Participant, entity _: CDParticipant) {}

    func update(models _: [CDParticipant]) {}

    func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: CDParticipant.entityName)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDParticipant) {}

    func getParticipantsForThread(_ threadId: Int?, _ count: Int?, _ offset: Int?, _ completion: @escaping ([CDParticipant], Int) -> Void) {
        let predicate = NSPredicate(format: "conversation.id == %i", threadId ?? -1)
        fetchWithOffset(entityName: CDParticipant.entityName, count: count, offset: offset, predicate: predicate, completion)
    }

    func delete(_ models: [Participant]) {
        let ids = models.compactMap(\.id)
        let predicate = NSPredicate(format: "id IN %@", ids)
        batchDelete(context, entityName: CDParticipant.entityName, predicate: predicate)
    }

    func findOrCreateEntity(_ threadId: Int?, _ participantId: Int?, _ completion: @escaping (CDParticipant?) -> Void) {
        first(threadId ?? -1, participantId ?? -1) { participant in
            completion(participant ?? CDParticipant.insertEntity(self.context))
        }
    }
}
