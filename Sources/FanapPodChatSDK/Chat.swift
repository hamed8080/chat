//
// Chat.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/16/22

import FanapPodAsyncSDK
import Foundation
import Sentry

public class Chat: ChatProtocol, Identifiable {
    public var id: UUID = .init()
    public var config: ChatConfig
    public weak var delegate: ChatDelegate?
    public var userInfo: User?
    internal var asyncManager: AsyncManager
    internal var logger: Logger?
    internal var userRetrycount = 0
    internal let maxUserRetryCount = 5
    var requestUserTimer: TimerProtocol
    var isTypingCount = 0
    var timerTyping: TimerProtocol?
    var timerCheckUserStoppedTyping: TimerProtocol?
    var callStartTimer: TimerProtocol?
    var exportMessageViewModels: [any ExportMessagesProtocol] = []
    var session: URLSessionProtocol
    var responseQueue: DispatchQueueProtocol
    var cache: CacheFactory
    var callState: CallState?
    public var webrtc: WebRTCClient?
    public weak var callDelegate: WebRTCClientDelegate?
    let callbacksManager = CallbacksManager()

    init(
        config: ChatConfig,
        logger: Logger? = nil,
        timerTyping: TimerProtocol? = Timer(),
        requestUserTimer: TimerProtocol = Timer(),
        timerCheckUserStoppedTyping: TimerProtocol? = Timer(),
        pingTimer: TimerProtocol = Timer(),
        queueTimer: TimerProtocol = Timer(),
        callStartTimer: TimerProtocol = Timer(),
        callDelegate: WebRTCClientDelegate? = nil,
        session: URLSessionProtocol = URLSession.shared,
        responseQueue: DispatchQueueProtocol = DispatchQueue.main
    ) {
        self.responseQueue = responseQueue
        self.config = config
        self.logger = logger ?? Logger(config: config)
        self.timerTyping = timerTyping
        self.callStartTimer = callStartTimer
        self.requestUserTimer = requestUserTimer
        self.timerCheckUserStoppedTyping = timerCheckUserStoppedTyping
        self.session = session
        self.callDelegate = callDelegate
        cache = CacheFactory(config: config)
        asyncManager = AsyncManager(pingTimer: pingTimer, queueTimer: queueTimer, config: config, delegate: delegate, logger: self.logger)
        asyncManager.chat = self
    }

    public func connect() {
        if config.captureLogsOnSentry == true {
            startCrashAnalytics()
        }

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
