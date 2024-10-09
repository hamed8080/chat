//
// CallState.swift
// Copyright (c) 2022 ChatCore
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import Async

public struct CallConfig: Codable {
    public private(set) var targetVideoWidth: Int
    public private(set) var targetVideoHeight: Int
    public private(set) var targetFPS: Int
    public private(set) var callTimeout: TimeInterval
    public private(set) var maxActiveVideoSessions: Int
    public private(set) var logWebRTC: Bool

    // Memberwise Initializer
    public init(
        targetVideoWidth: Int = 1920,
        targetVideoHeight: Int = 1080,
        targetFPS: Int = 60,
        callTimeout: TimeInterval = 45,
        maxActiveVideoSessions: Int = 4,
        logWebRTC: Bool = false
    ) {
        self.targetVideoWidth = targetVideoWidth
        self.targetVideoHeight = targetVideoHeight
        self.targetFPS = targetFPS
        self.callTimeout = callTimeout
        self.maxActiveVideoSessions = maxActiveVideoSessions
        self.logWebRTC = logWebRTC
    }
}

public class CallConfigBuilder {
    private(set) var targetVideoWidth: Int = 1920
    private(set) var targetVideoHeight: Int = 1080
    private(set) var targetFPS: Int = 60
    private(set) var callTimeout: TimeInterval = 45
    private(set) var maxActiveVideoSessions: Int = 4
    private(set) var logWebRTC: Bool = false

    public init() {}

    @discardableResult public func targetVideoWidth(_ targetVideoWidth: Int) -> CallConfigBuilder {
        self.targetVideoWidth = targetVideoWidth
        return self
    }

    @discardableResult public func targetVideoHeight(_ targetVideoHeight: Int) -> CallConfigBuilder {
        self.targetVideoHeight = targetVideoHeight
        return self
    }

    @discardableResult public func targetFPS(_ targetFPS: Int) -> CallConfigBuilder {
        self.targetFPS = targetFPS
        return self
    }

    @discardableResult public func callTimeout(_ callTimeout: TimeInterval) -> CallConfigBuilder {
        self.callTimeout = callTimeout
        return self
    }

    @discardableResult public func maxActiveVideoSessions(_ maxActiveVideoSessions: Int) -> CallConfigBuilder {
        self.maxActiveVideoSessions = maxActiveVideoSessions
        return self
    }

    @discardableResult public func logWebRTC(_ logWebRTC: Bool) -> CallConfigBuilder {
        self.logWebRTC = logWebRTC
        return self
    }

    public func build() -> CallConfig {
        CallConfig(
            targetVideoWidth: targetVideoWidth,
            targetVideoHeight: targetVideoHeight,
            targetFPS: targetFPS,
            callTimeout: callTimeout,
            maxActiveVideoSessions: maxActiveVideoSessions,
            logWebRTC: logWebRTC
        )
    }
}
