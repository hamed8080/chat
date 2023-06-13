//
// SystemManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/14/22

import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation
import Additive
import ChatExtensions

final class SystemManager: SystemProtocol, InternalSystemProtocol {
    let chat: ChatInternalProtocol
    var isTypingCount: Int = 0
    var timerTyping: TimerProtocol?
    var timerCheckUserStoppedTyping: TimerProtocol?

    init(chat: ChatInternalProtocol) {
        self.chat = chat
    }

    func onSystemMessageEvent(_ asyncMessage: AsyncMessage) {
        let response: ChatResponse<SystemEventMessageModel> = asyncMessage.toChatResponse()
        chat.delegate?.chatEvent(event: .system(.systemMessage(response)))
    }

    func snedStartTyping(threadId: Int) {
        if isSendingIsTypingStarted() {
            stopTimerWhenUserIsNotTyping()
            return
        }
        isTypingCount = 0
        timerTyping = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            if self?.isTypingCount ?? 0 < 30 {
                self?.isTypingCount += 1
                self?.chat.responseQueue.async {
                    self?.sendSignalMessage(req: .init(signalType: .isTyping, threadId: threadId))
                }
            } else {
                self?.sendStopTyping()
            }
        }
        stopTimerWhenUserIsNotTyping()
    }

    func sendStopTyping() {
        timerTyping?.invalidateTimer()
        timerTyping = nil
        isTypingCount = 0
    }

    func isSendingIsTypingStarted() -> Bool {
        timerTyping != nil
    }

    func stopTimerWhenUserIsNotTyping() {
        timerCheckUserStoppedTyping?.invalidateTimer()
        timerCheckUserStoppedTyping = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.sendStopTyping()
        }
    }

    func sendSignalMessage(req: SendSignalMessageRequest) {
        chat.prepareToSendAsync(req: req, type: .systemMessage)
    }

    func onError(_ asyncMessage: AsyncMessage) {
        chat.logger.logJSON(title: "onError:", jsonString: asyncMessage.string ?? "", persist: true, type: .received, userInfo: chat.loggerUserInfo)
        let chatMessage = asyncMessage.chatMessage
        let data = chatMessage?.content?.data(using: .utf8) ?? Data()
        let chatError = try? JSONDecoder.instance.decode(ChatError.self, from: data)
        let response = ChatResponse(uniqueId: chatMessage?.uniqueId, result: Optional<Any>.none, error: chatError)
        error(response: response)
    }

    func error(response: ChatResponse<Any>) {
        chat.delegate?.chatEvent(event: .system(.error(response)))
    }
}
