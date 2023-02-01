//
//  CacheManager.swift
//
//
//  Created by hamed on 1/13/23.
//

import Foundation

class CacheManager {
    var logger: Logger?
    var assistant: CacheAssistantManager?
    var contact: CacheContactManager?
    var conversation: CacheConversationManager?
    var file: CacheCoreDataFileManager?
    var forwardInfo: CacheForwardInfoManager?
    var image: CacheImageManager?
    var log: CacheLogManager?
    var message: CacheMessageManager?
    var mutualGroup: CacheMutualGroupManager?
    var participant: CacheParticipantManager?
    var editQueue: CacheQueueOfEditMessagesManager?
    var textQueue: CacheQueueOfTextMessagesManager?
    var forwardQueue: CacheQueueOfForwardMessagesManager?
    var fileQueue: CacheQueueOfFileMessagesManager?
    var replyInfo: CacheReplyInfoManager?
    var tag: CacheTagManager?
    var tagParticipant: CacheTagParticipantManager?
    var user: CacheUserManager?
    var userRole: CacheUserRoleManager?

    init() {}

    func update(pm: PersistentManager, logger: Logger? = nil) {
        self.logger = logger
        guard let context = pm.context else { return }
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
