//
// AsyncReconnectManager.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
import Additive
import Logger

@AsyncGlobalActor
class AsyncReconnectManager {
    private var reconnectTimer: SourceTimer?
    /// The number of retries that have happened to connect to the async server.
    private var retryCount: Int = 0
    private var debug = ProcessInfo().environment["ENABLE_ASYNC_RECONNECT_MANAGER_LOGGING"] == "1"
    internal var callback: ((NSError?) -> Void)?
    private let logger: Logger
    private let maxReconnect: Int
    
    init(maxReconnect: Int, logger: Logger) {
        self.maxReconnect = maxReconnect
        self.logger = logger
    }
    
    public func restart(duration: TimeInterval) {
        stop()
        log("restarting reconnect timer, it will trigger in \(duration)")
        reconnectTimer = SourceTimer()
        reconnectTimer?.start(duration: duration) { [weak self] in
            Task { @AsyncGlobalActor [weak self] in
                guard let self = self else { return }
                self.onReconnectTimer()
            }
        }
    }
    
    private func onReconnectTimer() {
        if retryCount < maxReconnect {
            retryCount += 1
            logger.log(message: "Try reconnect for \(retryCount) times", persist: false, type: .internalLog)
            log("Try reconnect for \(retryCount) times")
            callback?(nil)
        } else {
            let error = NSError(domain: "Failed to reconnect to the Async server.", code: NSURLErrorCannotConnectToHost)
            logger.log(message: "Failed to reconnect after \(maxReconnect) tries", persist: false, type: .internalLog)
            log("Failed to reconnect after \(maxReconnect) tries")
            stop()
            callback?(error)
        }
    }
    
    private func stop() {
        log("stopping reconnect timer")
        reconnectTimer?.cancel()
        reconnectTimer = nil
    }
    
    public func resetAndStop() {
        stop()
        retryCount = 0
    }
    
    private func log(_ message: String) {
#if DEBUG
        if debug {
            logger.log(title: "AsyncReconnectManager", message: message, persist: false, type: .internalLog)
        }
#endif
    }
}
