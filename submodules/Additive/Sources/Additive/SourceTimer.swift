//
// SourceTimer.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

open class SourceTimer {
    private var timer: DispatchSourceTimer?
    public init(){}
    private let queue = DispatchQueue(label: "SourceTimerSerilaQueue")

    public func start(duration: TimeInterval, completion: @escaping @Sendable () -> Void) {
        queue.sync {
            startTimer(duration: duration, completion: completion)
        }
    }

    private func startTimer(duration: TimeInterval, completion: @escaping @Sendable () -> Void) {
        // Create a new DispatchSourceTimer
        timer = DispatchSource.makeTimerSource()

        // Set the timer parameters
        timer?.schedule(deadline: .now() + duration)

        // Set the timer event handler
        timer?.setEventHandler { [weak self] in
            self?.queue.sync {
                self?.onEventHandler(completion: completion)
            }
        }

        // Start the timer
        timer?.resume()
    }

    private func onEventHandler(completion: @escaping @Sendable () -> Void) {
        if timer?.isCancelled == false {
            completion()
            timer?.cancel()
        }
    }

    public func cancel() {
        queue.sync {
            // Cancel and release the timer
            timer?.cancel()
            timer = nil
        }
    }
}
