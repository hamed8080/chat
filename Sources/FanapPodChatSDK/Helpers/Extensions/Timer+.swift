//
// Timer+.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
protocol TimerProtocol {
//    init(interval: TimeInterval, repeats: Bool, block: @escaping @Sendable (Timer) -> Void)
    @discardableResult
    func scheduledTimer(interval: TimeInterval, repeats: Bool, block: @escaping @Sendable (Timer) -> Void) -> Timer
    func invalidateTimer()
}

extension Timer: TimerProtocol {
//    convenience init(interval: TimeInterval, repeats: Bool, block: @escaping @Sendable (Timer) -> Void) {
//        self.init(timeInterval: interval, repeats: repeats, block: block)
//    }
    
    @discardableResult
    func scheduledTimer(interval: TimeInterval, repeats: Bool, block: @escaping @Sendable (Timer) -> Void) -> Timer {
        Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats, block: block)
    }
    
    func invalidateTimer() {
        invalidate()
    }
}
