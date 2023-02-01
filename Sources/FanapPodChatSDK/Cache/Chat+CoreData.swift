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
        guard let bgTask = persistentManager.newBgTask() else { return }
        bgTask.perform { [weak self] in
            var objectIds: [NSManagedObjectID] = []
            self?.entities.forEach { entity in
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.name ?? "")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                deleteRequest.resultType = .resultTypeObjectIDs
                if let result = try? bgTask.execute(deleteRequest) as? NSBatchDeleteResult, let ids = result.result as? [NSManagedObjectID] {
                    objectIds.append(contentsOf: ids)
                }
                try? bgTask.save()
                self?.mergeChanges(key: NSDeletedObjectsKey, objectIds)
            }
        }
    }

    func mergeChanges(key: String, _ objectIDs: [NSManagedObjectID]) {
        guard let context = persistentManager.context else { return }
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [key: objectIDs],
            into: [context]
        )
    }

    func deleteQueues(uniqueIds: [String]) {
        cache?.editQueue?.delete(uniqueIds)
        cache?.fileQueue?.delete(uniqueIds)
        cache?.textQueue?.delete(uniqueIds)
        cache?.forwardQueue?.delete(uniqueIds)
    }
}
