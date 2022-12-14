//
// SendStartTypingRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

extension Chat {
    func requestStartTyping(_ threadId: Int, onEndStartTyping _: (() -> Void)? = nil) {
        if isSendingIsTypingStarted() {
            stopTimerWhenUserIsNotTyping()
            return
        }
        isTypingCount = 0
        timerTyping = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            if self?.isTypingCount ?? 0 < 30 {
                self?.isTypingCount += 1
                DispatchQueue.main.async {
                    self?.sendSignalMessage(req: .init(signalType: .isTyping, threadId: threadId))
                }
            } else {
                self?.stopTyping()
            }
        }
        stopTimerWhenUserIsNotTyping()
    }

    func isSendingIsTypingStarted() -> Bool {
        timerTyping != nil
    }

    func stopTimerWhenUserIsNotTyping() {
        timerCheckUserStoppedTyping?.invalidate()
        timerCheckUserStoppedTyping = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.stopTyping()
        }
    }

    func stopTyping() {
        timerTyping?.invalidate()
        timerTyping = nil
        isTypingCount = 0
    }
}
