//
// AsyncManager.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 12/16/22

import FanapPodAsyncSDK
import Foundation

/// AsyncManager intermediate between chat and async socket server.
internal class AsyncManager: AsyncDelegate {
    private var config: ChatConfig? { chat?.config }
    private var logger: Logger? { chat?.logger }
    weak var chat: ChatProtocol?
    /// Async client.
    private(set) var asyncClient: Async?

    /// Last message date that was received from the server to manage ping status.
    private var lastSentMessageDate: Date? = Date()

    /// A timer to check the connection status every 20 seconds.
    private(set) var pingTimer: TimerProtocol
    private(set) var queueTimer: TimerProtocol

    /// This queue will live till application is running and this class is in memory, be careful it's not persistent on storage.
    private var queue: [String: Queueable] = [:]

    public init(pingTimer: TimerProtocol, queueTimer: TimerProtocol) {
        self.pingTimer = pingTimer
        self.queueTimer = queueTimer
    }

    /// Create an async connection.
    public func createAsync() {
        if let asyncConfig = config?.asyncConfig {
            asyncClient = Async(config: asyncConfig, delegate: self)
            asyncClient?.createSocket()
        }
    }

    /// A delegate method that receives a message.
    public func asyncMessage(asyncMessage: AsyncMessage) {
        chat?.invokeCallback(asyncMessage: asyncMessage)
        if let ban = asyncMessage.banError {
            scheduleForResendQueues(ban)
        } else {
            removeFromQueue(asyncMessage: asyncMessage)
        }
    }

    /// A delegate that tells the status of the async connection.
    public func asyncStateChanged(asyncState: AsyncSocketState, error: AsyncError?) {
        chat?.state = asyncState.chatState
        chat?.delegate?.chatState(state: asyncState.chatState, currentUser: nil, error: error?.chatError)
        if asyncState == .asyncReady {
            chat?.getUserForChatReady()
        } else if asyncState == .closed {
            pingTimer.invalidateTimer()
            logger?.log(message: "Socket Disconnected", persist: false, level: LogLevel.error, type: .received)
        }
    }

    /// It will be only used whenever a client implements a custom async class by itself.
    func asyncMessageSent(message _: Data?, error _: AsyncError?) {}

    /// A delegate to raise an error.
    public func asyncError(error: AsyncError) {
        chat?.delegate?.chatError(error: .init(type: .asyncError, message: error.message, userInfo: error.userInfo, rawError: error.rawError))
    }

    /// A public method to completely destroy the async object.
    public func disposeObject() {
        asyncClient?.disposeObject()
        asyncClient = nil
        pingTimer.invalidateTimer()
        queueTimer.invalidateTimer()
    }

    /// The sendData delegate will inform if a send event occurred by the async socket.
    public func sendData(sendable: ChatSendable) {
        guard let config = config else { return }
        let chatMessage = SendChatMessageVO(req: sendable, token: config.token, typeCode: config.typeCode)
        addToQueue(sendable: sendable)
        sendToAsync(asyncMessage: AsyncChatServerMessage(chatMessage: chatMessage), type: sendable.chatMessageType)
        sendPingTimer()
    }

    private func addToQueue(sendable: ChatSendable) {
        if let queueable = sendable as? Queueable {
            queue[sendable.uniqueId] = queueable
        }
    }

    private func removeFromQueue(asyncMessage: AsyncMessage) {
        if let uniqueId = SendChatMessageVO(with: asyncMessage)?.uniqueId, queue[uniqueId] != nil {
            queue.removeValue(forKey: uniqueId)
        }
    }

    /// Send queueable each one by one after ``ChatState.chatReady`` with 2 seconds interval between each message to prevent server rejection.
    func sendQueuesOnReconnect() {
        var interval: TimeInterval = 0
        queue.sorted { $0.value.queueTime < $1.value.queueTime }.forEach { _, item in
            if let sendable = item as? ChatSendable {
                queueTimer.scheduledTimer(interval: interval + 2, repeats: false) { [weak self] _ in
                    self?.sendData(sendable: sendable)
                }
            }
            interval += 2
        }
    }

    func sendToAsync(asyncMessage: AsyncSnedable, type: ChatMessageVOTypes) {
        guard let config = config, let content = asyncMessage.content else { return }
        let asyncMessage = SendAsyncMessageVO(content: content,
                                              ttl: config.msgTTL,
                                              peerName: asyncMessage.peerName ?? config.asyncConfig.serverName,
                                              priority: config.msgPriority,
                                              uniqueId: (asyncMessage as? AsyncChatServerMessage)?.chatMessage.uniqueId)
        guard chat?.state == .chatReady || chat?.state == .asyncReady else { return }
        logger?.logJSON(title: "send Message with type: \(type)", jsonString: asyncMessage.string ?? "", persist: false, type: .sent)
        asyncClient?.sendData(type: .message, message: asyncMessage)
    }

    /// A timer that repeats ping the `Chat server` every 20 seconds.
    internal func sendPingTimer() {
        pingTimer.invalidateTimer()
        pingTimer = pingTimer.scheduledTimer(interval: 20, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if let lastSentMessageDate = self.lastSentMessageDate, Date().timeIntervalSince1970 - (lastSentMessageDate.timeIntervalSince1970 + 20) > 20 {
                self.sendChatServerPing()
            }
        }
    }

    /// It's different from ping in async SDK you need to send a ping to the chat server to keep peerId
    /// If you don't send a ping to the chat server it clears peerId within the 30s to 1 minute and the chat server cannot send messages to the client like new chat inside the thread
    private func sendChatServerPing() {
        let req = BareChatSendableRequest()
        req.chatMessageType = .ping
        sendData(sendable: req)
    }

    /// When a user rapidly sends an action to the Async server, they'll be banned by Async Server.
    /// Due to this matter, we should reschedule a timer to start sending all messages inside the queue.
    private func scheduleForResendQueues(_ ban: BanError) {
        chat?.banTimer.scheduledTimer(interval: TimeInterval((ban.duration ?? 5000) / 1000) + 1, repeats: false) { [weak self] _ in
            self?.sendQueuesOnReconnect()
        }
    }
}
