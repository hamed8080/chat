//
//  Chat+CoreData.swift
//
//
//  Created by hamed on 1/7/23.
//

import CoreData
import Foundation

public extension Chat {
    var entities: [NSEntityDescription] {
        [
            CDTag.entity(),
            CDParticipant.entity(),
            CDConversation.entity(),
            CDTagParticipant.entity(),
            CDMessage.entity(),
            CDLog.entity(),
            CDReplyInfo.entity(),
            CDUserRole.entity(),
            CDUser.entity(),
            CDQueueOfEditMessages.entity(),
            CDQueueOfFileMessages.entity(),
            CDQueueOfTextMessages.entity(),
            CDQueueOfForwardMessages.entity(),
            CDFile.entity(),
            CDImage.entity(),
            CDAssistant.entity(),
            CDForwardInfo.entity(),
            CDMutualGroup.entity(),
            CDContact.entity(),
        ]
    }

    func truncate() {
        let bgTask = persistentManager.newBgTask()
        bgTask.perform { [weak self] in
            var objectIds: [NSManagedObjectID] = []
            self?.entities.forEach { entity in
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.name ?? "")
                fetchRequest.resultType = .managedObjectIDResultType
                if let result = try? bgTask.execute(fetchRequest) as? NSBatchDeleteResult, let ids = result.result as? [NSManagedObjectID] {
                    objectIds.append(contentsOf: ids)
                }
            }
            try? bgTask.save()
            self?.mergeChanges(key: NSDeletedObjectsKey, objectIds)
        }
    }

    func mergeChanges(key: String, _ objectIDs: [NSManagedObjectID]) {
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [key: objectIDs],
            into: [persistentManager.context]
        )
    }

    func deleteQueues(uniqueIds: [String]) {
        CacheQueueOfEditMessagesManager(pm: persistentManager, logger: logger).delete(uniqueIds)
        CacheQueueOfFileMessagesManager(pm: persistentManager, logger: logger).delete(uniqueIds)
        CacheQueueOfTextMessagesManager(pm: persistentManager, logger: logger).delete(uniqueIds)
        CacheQueueOfForwardMessagesManager(pm: persistentManager, logger: logger).delete(uniqueIds)
    }
}
