//
// ChatImplementation.swift
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

public final class ChatImplementation: ChatInternalProtocol, Identifiable {
    public var id: UUID = .init()
    public var config: ChatConfig
    public weak var delegate: ChatDelegate? {
        didSet {
            logger.delegate = delegate
        }
    }

    public var userInfo: User?
    public var asyncManager: AsyncManager
    public var logger: Logger
    public var userRetrycount = 0
    public let maxUserRetryCount = 5
    public var requestUserTimer: TimerProtocol
    public var isTypingCount = 0
    public var timerTyping: TimerProtocol?
    public var timerCheckUserStoppedTyping: TimerProtocol?
    public var banTimer: TimerProtocol
    public var exportMessageViewModels: [ExportMessagesProtocol] = []
    public var session: URLSessionProtocol
    public var responseQueue: DispatchQueueProtocol
    public var cache: CacheManager?
    public var persistentManager: ChatCache.PersistentManager
    public let callbacksManager = CallbacksManager()
    public var cacheFileManager: CacheFileManagerProtocol?
    public var state: ChatState = .uninitialized
    public var callMessageDeleaget: CallMessageProtocol?
    public var callDelegate: WebRTCClientDelegate?

    public init(config: ChatConfig,
                timerTyping: TimerProtocol = Timer(),
                requestUserTimer: TimerProtocol = Timer(),
                timerCheckUserStoppedTyping: TimerProtocol? = Timer(),
                pingTimer: TimerProtocol = Timer(),
                queueTimer: TimerProtocol = Timer(),
                banTimer: TimerProtocol = Timer(),
                session: URLSessionProtocol = URLSession.shared,
                callDelegate: WebRTCClientDelegate? = nil,
                responseQueue: DispatchQueueProtocol = DispatchQueue.main)
    {
        self.responseQueue = responseQueue
        self.config = config
        logger = Logger(config: config.loggerConfig)
        self.timerTyping = timerTyping
        self.banTimer = banTimer
        self.requestUserTimer = requestUserTimer
        self.timerCheckUserStoppedTyping = timerCheckUserStoppedTyping
        self.session = session
        self.callDelegate = callDelegate
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

    public func prepareToSendAsync<T: Decodable>(
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

    public func prepareToSendAsync(req: ChatSendable, type: ChatMessageVOTypes, uniqueIdResult: UniqueIdResultType? = nil) {
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
