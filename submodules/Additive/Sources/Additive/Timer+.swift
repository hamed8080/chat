//
// Timer+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
public protocol TimerProtocol {
    @discardableResult
    func scheduledTimer(interval: TimeInterval, repeats: Bool, block: @escaping @Sendable (TimerProtocol) -> Void) -> TimerProtocol
    func invalidateTimer()
    var isValid: Bool { get }
    func fire()
}

extension Timer: TimerProtocol {
    @discardableResult
    public func scheduledTimer(interval: TimeInterval, repeats: Bool, block: @escaping @Sendable (TimerProtocol) -> Void) -> TimerProtocol {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: block)
    }

    public func invalidateTimer() {
        invalidate()
    }
}
