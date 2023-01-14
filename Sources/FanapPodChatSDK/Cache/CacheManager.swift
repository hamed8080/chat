//
//  CacheManager.swift
//
//
//  Created by hamed on 1/13/23.
//

import Foundation

class CacheManager {
    let logger: Logger?
    let assistant: CacheAssistantManager?
    let contact: CacheContactManager?
    let conversation: CacheConversationManager?
    let file: CacheCoreDataFileManager?
    let forwardInfo: CacheForwardInfoManager?
    let image: CacheImageManager?
    let log: CacheLogManager?
    let message: CacheMessageManager?
    let mutualGroup: CacheMutualGroupManager?
    let participant: CacheParticipantManager?
    let editQueue: CacheQueueOfEditMessagesManager?
    let textQueue: CacheQueueOfTextMessagesManager?
    let forwardQueue: CacheQueueOfForwardMessagesManager?
    let fileQueue: CacheQueueOfFileMessagesManager?
    let replyInfo: CacheReplyInfoManager?
    let tag: CacheTagManager?
    let tagParticipant: CacheTagParticipantManager?
    let user: CacheUserManager?
    let userRole: CacheUserRoleManager?

    init(pm: PersistentManager, logger: Logger? = nil) {
        self.logger = logger
        let context = pm.context
        assistant = CacheAssistantManager(context: context, pm: pm, logger: logger)
        contact = CacheContactManager(context: context, pm: pm, logger: logger)
        conversation = CacheConversationManager(context: context, pm: pm, logger: logger)
        file = CacheCoreDataFileManager(context: context, pm: pm, logger: logger)
        forwardInfo = CacheForwardInfoManager(context: context, pm: pm, logger: logger)
        image = CacheImageManager(context: context, pm: pm, logger: logger)
        log = CacheLogManager(context: context, pm: pm, logger: logger)
        message = CacheMessageManager(context: context, pm: pm, logger: logger)
        mutualGroup = CacheMutualGroupManager(context: context, pm: pm, logger: logger)
        participant = CacheParticipantManager(context: context, pm: pm, logger: logger)
        editQueue = CacheQueueOfEditMessagesManager(context: context, pm: pm, logger: logger)
        textQueue = CacheQueueOfTextMessagesManager(context: context, pm: pm, logger: logger)
        forwardQueue = CacheQueueOfForwardMessagesManager(context: context, pm: pm, logger: logger)
        fileQueue = CacheQueueOfFileMessagesManager(context: context, pm: pm, logger: logger)
        replyInfo = CacheReplyInfoManager(context: context, pm: pm, logger: logger)
        tag = CacheTagManager(context: context, pm: pm, logger: logger)
        tagParticipant = CacheTagParticipantManager(context: context, pm: pm, logger: logger)
        user = CacheUserManager(context: context, pm: pm, logger: logger)
        userRole = CacheUserRoleManager(context: context, pm: pm, logger: logger)
    }
}
