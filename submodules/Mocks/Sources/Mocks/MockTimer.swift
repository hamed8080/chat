//
// MockTimer.swift
// Copyright (c) 2022 Mocks
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import Additive

open class MockTimer: TimerProtocol {
    public var blockResult: ((TimerProtocol) -> Void)?
    public var isValid: Bool = false

    public init() {}

    public func scheduledTimer(interval: TimeInterval, repeats: Bool, block: @escaping @Sendable (TimerProtocol) -> Void) -> TimerProtocol {
        isValid = true
        if let blockResult {
            blockResult(self)
            return self
        }
        self.blockResult = block
        return self
    }

    public func invalidateTimer() {
        isValid = false
    }

    public func fire() {
        blockResult?(self)
    }
}
