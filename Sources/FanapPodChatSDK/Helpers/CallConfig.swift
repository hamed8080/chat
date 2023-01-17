//
// CallConfig.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/16/22

import FanapPodAsyncSDK
import Foundation

public struct CallConfig: Codable {
    public private(set) var targetVideoWidth: Int = 1920
    public private(set) var targetVideoHeight: Int = 1080
    public private(set) var targetFPS: Int = 60
    public private(set) var callTimeout: TimeInterval = 45

    // Memberwise Initializer
    public init(
        targetVideoWidth: Int,
        targetVideoHeight: Int,
        targetFPS: Int,
        callTimeout: TimeInterval
    ) {
        self.targetVideoWidth = targetVideoWidth
        self.targetVideoHeight = targetVideoHeight
        self.targetFPS = targetFPS
        self.callTimeout = callTimeout
    }
}

public class CallConfigBuilder {
    private(set) var targetVideoWidth: Int = 1920
    private(set) var targetVideoHeight: Int = 1080
    private(set) var targetFPS: Int = 60
    private(set) var callTimeout: TimeInterval = 45

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

    public func build() -> CallConfig {
        CallConfig(
            targetVideoWidth: targetVideoWidth,
            targetVideoHeight: targetVideoHeight,
            targetFPS: targetFPS,
            callTimeout: callTimeout
        )
    }
}
