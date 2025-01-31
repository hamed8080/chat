//
// AsyncPingManager.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
import Additive
import Logger

@AsyncGlobalActor
class AsyncPingManager {
    private var pingTimerFirst: SourceTimer?
    private var pingTimerSecond: SourceTimer?
    private var pingTimerThird: SourceTimer?
    private var debug = ProcessInfo().environment["ENABLE_ASYNC_PING_MANAGER_LOGGING"] == "1"
    internal var callback: ((NSError?) -> Void)?
    private let pingInterval: TimeInterval
    private let logger: Logger
    
    init(pingInterval: TimeInterval, logger: Logger) {
        self.pingInterval = pingInterval
        self.logger = logger
    }
    
    public func reschedule() {
        log("Rescheduling all timers by first stopping all of them, then scheduling all of them again")
        stopPingTimers()
        schedulePingTimers()
    }
    
    private func schedulePingTimers() {
        scheduleFirstTimer()
        scheduleSecondTimer()
        scheduleThirdTimer()
    }

    private func scheduleFirstTimer() {
        log("Scheduling the first timer, it will triggered in \(pingInterval)")
        pingTimerFirst = SourceTimer()
        pingTimerFirst?.start(duration: pingInterval) { [weak self] in
            Task { @AsyncGlobalActor [weak self] in
                guard let self = self else { return }
                self.callback?(nil)
            }
        }
    }

    private func scheduleSecondTimer() {
        log("Scheduling the second timer, it will be triggered in \(pingInterval + 3)")
        pingTimerSecond = SourceTimer()
        pingTimerSecond?.start(duration: pingInterval + 3) { [weak self] in
            Task { @AsyncGlobalActor [weak self] in
                guard let self = self else { return }
                self.callback?(nil)
            }
        }
    }

    private func scheduleThirdTimer() {
        log("Scheduling the third timer, it will be triggered in \(pingInterval + 3 + 2)")
        pingTimerThird = SourceTimer()
        pingTimerThird?.start(duration: pingInterval + 3 + 2) { [weak self] in
            let error = NSError(domain: "Failed to retrieve a ping from the Async server.", code: NSURLErrorCannotConnectToHost)
            Task { @AsyncGlobalActor [weak self] in
                guard let self = self else { return }
                self.callback?(error)
            }
        }
    }
    
    public func stopPingTimers() {
        log("stopping all timers")
        pingTimerFirst?.cancel()
        pingTimerFirst = nil
        pingTimerSecond?.cancel()
        pingTimerSecond = nil
        pingTimerThird?.cancel()
        pingTimerThird = nil
    }
    
    private func log(_ message: String) {
#if DEBUG
        if debug {
            logger.log(title: "AsyncPingManager", message: message, persist: false, type: .internalLog)
        }
#endif
    }
}
