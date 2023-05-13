//
// ChatImplementation+SendStartTyping.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation

public extension ChatImplementation {
    /// Send a event to the participants of a thread that you are typing something.
    /// - Parameter threadId: The id of the thread.
    func snedStartTyping(threadId: Int) {
        if isSendingIsTypingStarted() {
            stopTimerWhenUserIsNotTyping()
            return
        }
        isTypingCount = 0
        timerTyping = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            if self?.isTypingCount ?? 0 < 30 {
                self?.isTypingCount += 1
                self?.responseQueue.async {
                    self?.sendSignalMessage(req: .init(signalType: .isTyping, threadId: threadId))
                }
            } else {
                self?.sendStopTyping()
            }
        }
        stopTimerWhenUserIsNotTyping()
    }

    /// Send user stop typing.
    func sendStopTyping() {
        timerTyping?.invalidateTimer()
        timerTyping = nil
        isTypingCount = 0
    }
}

// Internal
extension ChatImplementation {
    func isSendingIsTypingStarted() -> Bool {
        timerTyping != nil
    }

    func stopTimerWhenUserIsNotTyping() {
        timerCheckUserStoppedTyping?.invalidateTimer()
        timerCheckUserStoppedTyping = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.sendStopTyping()
        }
    }
}
