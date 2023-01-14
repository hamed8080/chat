//
//  CacheMutualGroupManager.swift
//
//
//  Created by hamed on 1/11/23.
//

import CoreData
import Foundation

class CacheMutualGroupManager: CoreDataProtocol {
    let idName = "id"
    let pm: PersistentManager
    var context: NSManagedObjectContext
    let logger: Logger?
    let entityName = CDMutualGroup.entity().name ?? ""

    required init(context: NSManagedObjectContext? = nil, pm: PersistentManager, logger: Logger? = nil) {
        self.context = context ?? pm.context
        self.pm = pm
        self.logger = logger
    }

    func insert(context: NSManagedObjectContext, model: MutualGroup) {
        let entity = CDMutualGroup(context: context)
        entity.update(model)
        model.conversations?.forEach { thread in
            let cm = CacheConversationManager(pm: pm, logger: logger)
            if let threadEntity = cm.first(with: thread.id ?? -1) {
                entity.addToConversations(threadEntity)
            }
        }
    }

    func insert(models: [MutualGroup]) {
        insertObjects { [weak self] bgTask in
            models.forEach { model in
                self?.insert(context: bgTask, model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int) -> CDMutualGroup? {
        let req = CDMutualGroup.fetchRequest()
        req.predicate = idPredicate(id: id)
        return try? context.fetch(req).first
    }

    func find(predicate: NSPredicate) -> [CDMutualGroup] {
        let req = CDMutualGroup.fetchRequest()
        req.predicate = predicate
        return (try? context.fetch(req)) ?? []
    }

    func update(model _: MutualGroup, entity _: CDMutualGroup) {}

    func update(models _: [MutualGroup]) {}

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

    func delete(entity _: CDMutualGroup) {}

    func insert(_ threads: [Conversation], _ req: MutualGroupsRequest) {
        let model = MutualGroup(idType: InviteeTypes(rawValue: req.toBeUserVO.idType ?? -1) ?? .unknown, mutualId: req.toBeUserVO.id, conversations: threads)
        insert(models: [model])
    }

    func mutualGroups(_ id: String?) -> [CDMutualGroup] {
        let req = CDMutualGroup.fetchRequest()
        req.predicate = NSPredicate(format: "mutualId == %@", id ?? "")
        return (try? context.fetch(req)) ?? []
    }
}
