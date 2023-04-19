//
//  CacheManager.swift
//
//
//  Created by hamed on 1/13/23.
//

import CoreData
import Foundation
import Logger
import ChatCore

public final class CacheManager: CacheManagerProtocol {
    public let assistant: CacheAssistantManager
    public let contact: CacheContactManager
    public let conversation: CacheConversationManager
    public let file: CacheCoreDataFileManager
    public let forwardInfo: CacheForwardInfoManager
    public let image: CacheImageManager
    public let message: CacheMessageManager
    public let mutualGroup: CacheMutualGroupManager
    public let participant: CacheParticipantManager
    public let editQueue: CacheQueueOfEditMessagesManager
    public let textQueue: CacheQueueOfTextMessagesManager
    public let forwardQueue: CacheQueueOfForwardMessagesManager
    public let fileQueue: CacheQueueOfFileMessagesManager
    public let replyInfo: CacheReplyInfoManager
    public let tag: CacheTagManager
    public let tagParticipant: CacheTagParticipantManager
    public let user: CacheUserManager
    public let userRole: CacheUserRoleManager
    var entities: [NSEntityDescription] {
        [
            CDTag.entity(),
            CDParticipant.entity(),
            CDConversation.entity(),
            CDTagParticipant.entity(),
            CDMessage.entity(),
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

    public init(context: NSManagedObjectContext, logger: Logger) {
        assistant = CacheAssistantManager(context: context, logger: logger)
        contact = CacheContactManager(context: context, logger: logger)
        conversation = CacheConversationManager(context: context, logger: logger)
        file = CacheCoreDataFileManager(context: context, logger: logger)
        forwardInfo = CacheForwardInfoManager(context: context, logger: logger)
        image = CacheImageManager(context: context, logger: logger)
        message = CacheMessageManager(context: context, logger: logger)
        mutualGroup = CacheMutualGroupManager(context: context, logger: logger)
        participant = CacheParticipantManager(context: context, logger: logger)
        editQueue = CacheQueueOfEditMessagesManager(context: context, logger: logger)
        textQueue = CacheQueueOfTextMessagesManager(context: context, logger: logger)
        forwardQueue = CacheQueueOfForwardMessagesManager(context: context, logger: logger)
        fileQueue = CacheQueueOfFileMessagesManager(context: context, logger: logger)
        replyInfo = CacheReplyInfoManager(context: context, logger: logger)
        tag = CacheTagManager(context: context, logger: logger)
        tagParticipant = CacheTagParticipantManager(context: context, logger: logger)
        user = CacheUserManager(context: context, logger: logger)
        userRole = CacheUserRoleManager(context: context, logger: logger)
    }

    public func truncate(bgTask: NSManagedObjectContext, context: NSManagedObjectContext) {
        bgTask.perform { [weak self] in
            var objectIds: [NSManagedObjectID] = []
            try self?.entities.forEach { entity in
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity.name ?? "")
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                deleteRequest.resultType = .resultTypeObjectIDs
                if let result = try bgTask.execute(deleteRequest) as? NSBatchDeleteResult, let ids = result.result as? [NSManagedObjectID] {
                    objectIds.append(contentsOf: ids)
                }
                try? bgTask.save()
                self?.mergeChanges(context: context, key: NSDeletedObjectsKey, objectIds)
            }
        }
    }

    public func mergeChanges(context: NSManagedObjectContext, key: String, _ objectIDs: [NSManagedObjectID]) {
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: [key: objectIDs],
            into: [context]
        )
    }

    public func deleteQueues(uniqueIds: [String]) {
        editQueue.delete(uniqueIds)
        fileQueue.delete(uniqueIds)
        textQueue.delete(uniqueIds)
        forwardQueue.delete(uniqueIds)
    }
}
