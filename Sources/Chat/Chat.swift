//
// Chat.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22

import Additive
import Async
import ChatCache
import ChatCore
import ChatDTO
import ChatModels
import Foundation
import Logger

public final class Chat: ChatProtocol, Identifiable {
    public var id: UUID = .init()
    public var config: ChatConfig
    public weak var delegate: ChatDelegate? {
        didSet {
            logger.delegate = delegate
        }
    }

    public var userInfo: User?
    internal var asyncManager: AsyncManager
    internal var logger: Logger
    internal var userRetrycount = 0
    internal let maxUserRetryCount = 5
    var requestUserTimer: TimerProtocol
    var isTypingCount = 0
    var timerTyping: TimerProtocol?
    var timerCheckUserStoppedTyping: TimerProtocol?
    var banTimer: TimerProtocol
    var exportMessageViewModels: [ExportMessagesProtocol] = []
    var session: URLSessionProtocol
    var responseQueue: DispatchQueueProtocol
    var cache: CacheManager?
    var persistentManager: ChatCache.PersistentManager
    let callbacksManager = CallbacksManager()
    public var cacheFileManager: CacheFileManagerProtocol?
    public internal(set) var state: ChatState = .uninitialized

    init(
        config: ChatConfig,
        timerTyping: TimerProtocol? = Timer(),
        requestUserTimer: TimerProtocol = Timer(),
        timerCheckUserStoppedTyping: TimerProtocol? = Timer(),
        pingTimer: TimerProtocol = Timer(),
        queueTimer: TimerProtocol = Timer(),
        banTimer: TimerProtocol = Timer(),
        session: URLSessionProtocol = URLSession.shared,
        responseQueue: DispatchQueueProtocol = DispatchQueue.main
    ) {
        self.responseQueue = responseQueue
        self.config = config
        logger = Logger(config: config.loggerConfig)
        self.timerTyping = timerTyping
        self.banTimer = banTimer
        self.requestUserTimer = requestUserTimer
        self.timerCheckUserStoppedTyping = timerCheckUserStoppedTyping
        self.session = session
        asyncManager = AsyncManager(pingTimer: pingTimer, queueTimer: queueTimer)
        persistentManager = PersistentManager(cacheEnabled: config.enableCache)
        if config.enableCache {
            persistentManager.logger = self
            cacheFileManager = CacheFileManager()
            if let context = persistentManager.newBgTask() {
                cache = CacheManager(context: context, logger: self)
            }
        }
        asyncManager.chat = self
    }

    public func connect() {
        if config.getDeviceIdFromToken == false {
            asyncManager.createAsync()
        } else {
            requestDeviceId()
        }
        DiskStatus.checkIfDeviceHasFreeSpace(needSpaceInMB: config.deviecLimitationSpaceMB, turnOffTheCache: true, errorDelegate: delegate)
    }

    public func dispose() {
        asyncManager.disposeObject()
        print("Disposed Singleton instance")
    }

    func prepareToSendAsync<T: Decodable>(
        req: ChatSendable,
        type: ChatMessageVOTypes,
        uniqueIdResult: UniqueIdResultType? = nil,
        completion: CompletionType<T>? = nil,
        onSent: OnSentType? = nil,
        onDelivered: OnDeliveryType? = nil,
        onSeen: OnSeenType? = nil
    ) {
        callbacksManager.addCallback(uniqueId: req.chatUniqueId, requesType: type, callback: completion, onSent: onSent, onDelivered: onDelivered, onSeen: onSeen)
        uniqueIdResult?(req.chatUniqueId)
        asyncManager.sendData(sendable: req, type: type)
    }

    func prepareToSendAsync(req: ChatSendable, type: ChatMessageVOTypes, uniqueIdResult: UniqueIdResultType? = nil) {
        uniqueIdResult?(req.chatUniqueId)
        asyncManager.sendData(sendable: req, type: type)
    }

    public func setToken(newToken: String, reCreateObject: Bool = false) {
        config.updateToken(newToken)
        if reCreateObject {
            asyncManager.createAsync()
        }
    }
}
