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
    let pm: PersistentManager
    var context: NSManagedObjectContext?
    let logger: Logger?
    let entityName = CDForwardInfo.entity().name ?? "CDForwardInfo"

    required init(context: NSManagedObjectContext? = nil, pm: PersistentManager, logger: Logger? = nil) {
        self.context = context ?? pm.context
        self.pm = pm
        self.logger = logger
    }

    func insert(context: NSManagedObjectContext, model: ForwardInfo) {
        let entity = CDForwardInfo(context: context)
        entity.update(model)
    }

    func insert(models: [ForwardInfo]) {
        insertObjects { [weak self] bgTask in
            models.forEach { model in
                self?.insert(context: bgTask, model: model)
            }
        }
    }

    func idPredicate(id: Int) -> NSPredicate {
        NSPredicate(format: "\(idName) == %i", id)
    }

    func first(with id: Int) -> CDForwardInfo? {
        let req = CDForwardInfo.fetchRequest()
        req.predicate = idPredicate(id: id)
        return try? context?.fetch(req).first
    }

    func find(predicate: NSPredicate) -> [CDForwardInfo] {
        let req = CDForwardInfo.fetchRequest()
        req.predicate = predicate
        return (try? context?.fetch(req)) ?? []
    }

    func update(model _: ForwardInfo, entity _: CDForwardInfo) {}

    func update(models _: [ForwardInfo]) {}

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

    func delete(entity _: CDForwardInfo) {}

    func first(_ messageId: Int?, _ threadId: Int?, _: Int?) -> CDForwardInfo? {
        let predicate = NSPredicate(format: "message.id == %i AND conversation.id == %i AND participant.id", messageId ?? -1, threadId ?? -1, threadId ?? -1)
        let req = CDForwardInfo.fetchRequest()
        req.predicate = predicate
        req.fetchLimit = 1
        return try? context?.fetch(req).first
    }

    func insert(_ forwardInfo: ForwardInfo, _ message: CDMessage) {
        guard let context = context else { return }
        let entity = CDForwardInfo(context: context)
        entity.message = message
        if let conversation = forwardInfo.conversation {
            let cmThread = CacheConversationManager(context: context, pm: pm, logger: logger)
            if let threadEntity = cmThread.first(with: conversation.id ?? -1) {
                entity.conversation = threadEntity
            } else {
                entity.conversation = CDConversation(context: context)
                entity.conversation?.update(conversation)
            }
        }

        if let participant = forwardInfo.participant {
            let cmThread = CacheParticipantManager(context: context, pm: pm, logger: logger)
            if let participantEntity = cmThread.first(with: participant.id ?? -1) {
                entity.participant = participantEntity
            } else {
                entity.participant = CDParticipant(context: context)
                entity.participant?.update(participant)
            }
        }
    }
}
