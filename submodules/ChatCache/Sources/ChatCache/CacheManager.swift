//
// CacheManager.swift
// Copyright (c) 2022 ChatCache
//
// Created by Hamed Hosseini on 12/14/22

import CoreData
import Foundation
import ChatModels

public final class CacheManager: @unchecked Sendable {
    internal let persistentManager: PersistentManagerProtocol
    public private(set) var assistant: CacheAssistantManager?
    public private(set) var contact: CacheContactManager?
    public private(set) var conversation: CacheConversationManager?
    public private(set) var file: CacheCoreDataFileManager?
    public private(set) var image: CacheImageManager?
    public private(set) var message: CacheMessageManager?
    public private(set) var mutualGroup: CacheMutualGroupManager?
    public private(set) var participant: CacheParticipantManager?
    public private(set) var editQueue: CacheQueueOfEditMessagesManager?
    public private(set) var textQueue: CacheQueueOfTextMessagesManager?
    public private(set) var forwardQueue: CacheQueueOfForwardMessagesManager?
    public private(set) var fileQueue: CacheQueueOfFileMessagesManager?
    public private(set) var tag: CacheTagManager?
    public private(set) var tagParticipant: CacheTagParticipantManager?
    public private(set) var user: CacheUserManager?
    public private(set) var userRole: CacheCurrentUserRoleManager?
    public private(set) var reactionCount: CacheReactionCountManager?

    public init(persistentManager: PersistentManagerProtocol) {
        self.persistentManager = persistentManager
    }

    public func setupManangers(){
        if let logger = persistentManager.logger {
            assistant = CacheAssistantManager(container: persistentManager, logger: logger)
            contact = CacheContactManager(container: persistentManager, logger: logger)
            conversation = CacheConversationManager(container: persistentManager, logger: logger)
            file = CacheCoreDataFileManager(container: persistentManager, logger: logger)
            image = CacheImageManager(container: persistentManager, logger: logger)
            message = CacheMessageManager(container: persistentManager, logger: logger)
            mutualGroup = CacheMutualGroupManager(container: persistentManager, logger: logger)
            participant = CacheParticipantManager(container: persistentManager, logger: logger)
            editQueue = CacheQueueOfEditMessagesManager(container: persistentManager, logger: logger)
            textQueue = CacheQueueOfTextMessagesManager(container: persistentManager, logger: logger)
            forwardQueue = CacheQueueOfForwardMessagesManager(container: persistentManager, logger: logger)
            fileQueue = CacheQueueOfFileMessagesManager(container: persistentManager, logger: logger)
            tag = CacheTagManager(container: persistentManager, logger: logger)
            tagParticipant = CacheTagParticipantManager(container: persistentManager, logger: logger)
            user = CacheUserManager(container: persistentManager, logger: logger)
            userRole = CacheCurrentUserRoleManager(container: persistentManager, logger: logger)
            reactionCount = CacheReactionCountManager(container: persistentManager, logger: logger)
        }
    }

    public func deleteQueues(uniqueIds: [String]) {
        editQueue?.delete(uniqueIds)
        fileQueue?.delete(uniqueIds)
        textQueue?.delete(uniqueIds)
        forwardQueue?.delete(uniqueIds)
    }

    public func switchToContainerOnMain(userId: Int, completion: (@Sendable () ->Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            self?.switchToContainer(userId: userId, completion: completion)
        }
    }

    public func switchToContainer(userId: Int, completion: (() ->Void)? = nil) {
        persistentManager.switchToContainer(userId: userId) { [weak self] in
            self?.setupManangers()
            completion?()
        }
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func switchToContainer(userId: Int) async -> Bool {
        typealias ContinuationType = CheckedContinuation<Bool, Never>
        return await withCheckedContinuation { [weak self] (continuation: ContinuationType) in
            self?.switchToContainer(userId: userId) {
                continuation.resume(returning: true)
            }
        }
    }

    public func delete() {
        persistentManager.delete()
    }

    public func truncate() {
        assistant?.truncate()
        contact?.truncate()
        conversation?.truncate()
        file?.truncate()
        image?.truncate()
        message?.truncate()
        mutualGroup?.truncate()
        participant?.truncate()
        tag?.truncate()
        tagParticipant?.truncate()
        user?.truncate()
        userRole?.truncate()
        reactionCount?.truncate()

        /// We do not need to truncate queues due to they are essential to continue sending text messages/images/files after the user connection is established.
//        editQueue?.truncate()
//        textQueue?.truncate()
//        forwardQueue?.truncate()
//        fileQueue?.truncate()
    }
}
