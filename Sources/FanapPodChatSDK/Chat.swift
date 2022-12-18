//
// Chat.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/16/22

import FanapPodAsyncSDK
import Foundation
import Sentry

protocol ChatProtocol {
    var id: UUID { get set }
    var callbacksManager: CallbacksManager { get }
    var config: ChatConfig { get set }
    var isTypingCount: Int { get set }
    var timerTyping: TimerProtocol? { get set }
    var requestUserTimer: TimerProtocol { get set }
    var asyncManager: AsyncManager { get set }
    var logger: Logger? { get set }
    var timerCheckUserStoppedTyping: TimerProtocol? { get set }
    var exportMessageViewModels: [any ExportMessagesProtocol] { get set }
    var session: URLSessionProtocol { get set }
    var responseQueue: DispatchQueueProtocol { get set }
    var cache: CacheFactory { get set }
    var userRetrycount: Int { get set }
    var maxUserRetryCount: Int { get }
    var userInfo: User? { get set }
    func setToken(newToken: String, reCreateObject: Bool)
    func prepareToSendAsync<T: Decodable>(
        req: ChatSendable,
        uniqueIdResult: UniqueIdResultType?,
        completion: CompletionType<T>?,
        onSent: OnSentType?,
        onDelivered: OnDeliveryType?,
        onSeen: OnSeenType?
    )
    func prepareToSendAsync(req: ChatSendable, uniqueIdResult: UniqueIdResultType?)
    func dispose()
    func connect()
    func startCrashAnalytics()
}

public class Chat: ChatProtocol, Identifiable {
    public var id: UUID = .init()
    public var config: ChatConfig
    /// Delegate to send events.
    public weak var delegate: ChatDelegate?
    /// Current user info of the application it'll be filled after chat is in the ``ChatState/chatReady``  state.
    public var userInfo: User?
    internal var asyncManager: AsyncManager
    internal var logger: Logger?
    internal var userRetrycount = 0
    internal let maxUserRetryCount = 5
    var isTypingCount = 0
    var timerTyping: TimerProtocol?
    var requestUserTimer: TimerProtocol
    var timerCheckUserStoppedTyping: TimerProtocol?
    var exportMessageViewModels: [any ExportMessagesProtocol] = []
    var session: URLSessionProtocol
    var responseQueue: DispatchQueueProtocol
    var cache: CacheFactory
    let callbacksManager = CallbacksManager()

    init(
        config: ChatConfig,
        logger: Logger? = nil,
        timerTyping: TimerProtocol? = Timer(),
        requestUserTimer: TimerProtocol = Timer(),
        timerCheckUserStoppedTyping: TimerProtocol? = Timer(),
        pingTimer: TimerProtocol = Timer(),
        queueTimer: TimerProtocol = Timer(),
        session: URLSessionProtocol = URLSession.shared,
        responseQueue: DispatchQueueProtocol = DispatchQueue.main
    ) {
        self.responseQueue = responseQueue
        self.config = config
        self.logger = logger ?? Logger(config: config)
        self.timerTyping = timerTyping
        self.requestUserTimer = requestUserTimer
        self.timerCheckUserStoppedTyping = timerCheckUserStoppedTyping
        self.session = session
        cache = CacheFactory(config: config)
        asyncManager = AsyncManager(pingTimer: pingTimer, queueTimer: queueTimer, config: config, delegate: delegate, logger: self.logger)
        asyncManager.chat = self
    }

    /// Create logger and then connect to async server.
    public func connect() {
        if config.captureLogsOnSentry == true {
            startCrashAnalytics()
        }

        if config.getDeviceIdFromToken == false {
            asyncManager.createAsync()
        } else {
            requestDeviceId()
        }
        _ = DiskStatus.checkIfDeviceHasFreeSpace(needSpaceInMB: config.deviecLimitationSpaceMB, turnOffTheCache: true, errorDelegate: delegate)
    }

    /// Closing the async socket if it is open and setting the chat shared instance to nil.
    /// You should take into consideration that if you need to work with this instance you should call the ``createChatObject(config:)`` method again.
    public func dispose() {
        asyncManager.disposeObject()
        print("Disposed Singleton instance")
    }

    func prepareToSendAsync<T: Decodable>(
        req: ChatSendable,
        uniqueIdResult: UniqueIdResultType? = nil,
        completion: CompletionType<T>? = nil,
        onSent: OnSentType? = nil,
        onDelivered: OnDeliveryType? = nil,
        onSeen: OnSeenType? = nil
    ) {
        callbacksManager.addCallback(uniqueId: req.uniqueId, requesType: req.chatMessageType, callback: completion, onSent: onSent, onDelivered: onDelivered, onSeen: onSeen)
        uniqueIdResult?(req.uniqueId)
        asyncManager.sendData(sendable: req)
    }

    func prepareToSendAsync(req: ChatSendable, uniqueIdResult: UniqueIdResultType? = nil) {
        uniqueIdResult?(req.uniqueId)
        asyncManager.sendData(sendable: req)
    }

    public func setToken(newToken: String, reCreateObject: Bool = false) {
        config.token = newToken
        if reCreateObject {
            asyncManager.createAsync()
        }
    }

    func startCrashAnalytics() {
        // Config for Sentry 4.3.1
        do {
            Client.shared = try Client(dsn: "https://5e236d8a40be4fe99c4e8e9497682333:5a6c7f732d5746e8b28625fcbfcbe58d@chatsentryweb.sakku.cloud/4")
            try Client.shared?.startCrashHandler()
        } catch {
            print("\(error)")
        }
    }
}
