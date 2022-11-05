//
// SendStartTypingRequestHandler.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation
class SendStartTypingRequestHandler {
    static var isTypingCount = 0
    static var timer: Timer?
    static var timerCheckUserStoppedTyping: Timer?

    class func handle(_ threadId: Int, _: Chat, onEndStartTyping _: (() -> Void)? = nil) {
        if isSendingIsTypingStarted() {
            stopTimerWhenUserIsNotTyping()
            return
        }
        isTypingCount = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.isTypingCount < 30 {
                self.isTypingCount += 1
                DispatchQueue.main.async {
                    Chat.sharedInstance.sendSignalMessage(req: .init(signalType: .isTyping, threadId: threadId))
                }
            } else {
                stopTyping()
            }
        }
        stopTimerWhenUserIsNotTyping()
    }

    class func isSendingIsTypingStarted() -> Bool {
        timer != nil
    }

    class func stopTimerWhenUserIsNotTyping() {
        timerCheckUserStoppedTyping?.invalidate()
        timerCheckUserStoppedTyping = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
            SendStartTypingRequestHandler.stopTyping()
        })
    }

    class func stopTyping() {
        timer?.invalidate()
        timer = nil
        isTypingCount = 0
    }
}
