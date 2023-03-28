//
//  CacheManager.swift
//
//
//  Created by hamed on 1/13/23.
//

import CoreData
import Foundation

final class CacheManager {
    let assistant: CacheAssistantManager
    let contact: CacheContactManager
    let conversation: CacheConversationManager
    let file: CacheCoreDataFileManager
    let forwardInfo: CacheForwardInfoManager
    let image: CacheImageManager
    let log: CacheLogManager
    let message: CacheMessageManager
    let mutualGroup: CacheMutualGroupManager
    let participant: CacheParticipantManager
    let editQueue: CacheQueueOfEditMessagesManager
    let textQueue: CacheQueueOfTextMessagesManager
    let forwardQueue: CacheQueueOfForwardMessagesManager
    let fileQueue: CacheQueueOfFileMessagesManager
    let replyInfo: CacheReplyInfoManager
    let tag: CacheTagManager
    let tagParticipant: CacheTagParticipantManager
    let user: CacheUserManager
    let userRole: CacheUserRoleManager

    init(context: NSManagedObjectContext, logger: Logger? = nil) {
        assistant = CacheAssistantManager(context: context, logger: logger)
        contact = CacheContactManager(context: context, logger: logger)
        conversation = CacheConversationManager(context: context, logger: logger)
        file = CacheCoreDataFileManager(context: context, logger: logger)
        forwardInfo = CacheForwardInfoManager(context: context, logger: logger)
        image = CacheImageManager(context: context, logger: logger)
        log = CacheLogManager(context: context, logger: logger)
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
}
