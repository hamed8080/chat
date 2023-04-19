//
//  CacheMutualGroupManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation
import Logger
import ChatModels
import ChatDTO

public final class CacheMutualGroupManager: CoreDataProtocol {
    let idName = "id"
    var context: NSManagedObjectContext
    let logger: Logger

    required init(context: NSManagedObjectContext, logger: Logger) {
        self.context = context
        self.logger = logger
    }

    func insert(model: MutualGroup) {
        let entity = CDMutualGroup.insertEntity(context)
        entity.update(model)
        model.conversations?.forEach { thread in
            CacheConversationManager(context: context, logger: logger).findOrCreateEntity(thread.id ?? -1) { threadEntity in
                if let threadEntity = threadEntity {
                    threadEntity.update(thread)
                    entity.addToConversations(threadEntity)
                }
            }
        }
    }

    public func insert(models: [MutualGroup]) {
        insertObjects(context) { [weak self] _ in
            models.forEach { model in
                self?.insert(model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    public func first(with id: Int, _ completion: @escaping (CDMutualGroup?) -> Void) {
        context.perform {
            let req = CDMutualGroup.fetchRequest()
            req.predicate = self.idPredicate(id: id)
            let mutual = try self.context.fetch(req).first
            completion(mutual)
        }
    }

    public func find(predicate: NSPredicate, _ completion: @escaping ([CDMutualGroup]) -> Void) {
        context.perform {
            let req = CDMutualGroup.fetchRequest()
            req.predicate = predicate
            let mutuals = try self.context.fetch(req)
            completion(mutuals)
        }
    }

    func update(model _: MutualGroup, entity _: CDMutualGroup) {}

    func update(models _: [MutualGroup]) {}

    public func update(_ propertiesToUpdate: [String: Any], _ predicate: NSPredicate) {
        // batch update request
        batchUpdate(context) { bgTask in
            let batchRequest = NSBatchUpdateRequest(entityName: CDMutualGroup.entityName)
            batchRequest.predicate = predicate
            batchRequest.propertiesToUpdate = propertiesToUpdate
            batchRequest.resultType = .updatedObjectIDsResultType
            _ = try? bgTask.execute(batchRequest)
        }
    }

    func delete(entity _: CDMutualGroup) {}

    public func insert(_ threads: [Conversation], _ req: MutualGroupsRequest) {
        let model = MutualGroup(idType: InviteeTypes(rawValue: req.toBeUserVO.idType ?? -1) ?? .unknown, mutualId: req.toBeUserVO.id, conversations: threads)
        insert(models: [model])
    }

    public func mutualGroups(_ id: String?, _ completion: @escaping ([CDMutualGroup]) -> Void) {
        context.perform {
            let req = CDMutualGroup.fetchRequest()
            req.predicate = NSPredicate(format: "mutualId == %@", id ?? "")
            let mutuals = try self.context.fetch(req)
            completion(mutuals)
        }
    }
}
