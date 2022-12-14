//
// AsyncManager.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

/// AsyncManager intermediate between chat and async socket server.
internal class AsyncManager: AsyncDelegate {
    private var config: ChatConfig?
    private weak var delegate: ChatDelegate?
    private var logger: Logger?
    var chat: Chat!
    /// Async client.
    private(set) var asyncClient: Async?

    /// Last message date that was received from the server to manage ping status.
    private var lastSentMessageDate: Date? = Date()

    /// A timer to check the connection status every 20 seconds.
    private(set) var pingTimer: TimerProtocol
    private(set) var queueTimer: TimerProtocol

    /// This queue will live till application is running and this class is in memory, be careful it's not persistent on storage.
    private var queue: [String: Queueable] = [:]

    public init(pingTimer: TimerProtocol, queueTimer: TimerProtocol, config: ChatConfig?, delegate: ChatDelegate?, logger: Logger?) {
        self.config = config
        self.delegate = delegate
        self.logger = logger
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
        chat.invokeCallback(asyncMessage: asyncMessage)
        removeFromQueue(asyncMessage: asyncMessage)
    }

    /// A delegate that tells the status of the async connection.
    public func asyncStateChanged(asyncState: AsyncSocketState, error: AsyncError?) {
        delegate?.chatState(state: asyncState.chatState, currentUser: nil, error: error?.chatError)
        if asyncState == .asyncReady {
            chat.getUserForChatReady()
        } else if asyncState == .closed {
            pingTimer.invalidate()
        }
    }

    /// It will be only used whenever a client implements a custom async class by itself.
    func asyncMessageSent(message _: Data?, error _: AsyncError?) {}

    /// A delegate to raise an error.
    public func asyncError(error: AsyncError) {
        delegate?.chatError(error: .init(code: .asyncError, message: error.message, userInfo: error.userInfo, rawError: error.rawError))
    }

    /// A public method to completely destroy the async object.
    public func disposeObject() {
        asyncClient?.disposeObject()
        asyncClient = nil
        pingTimer.invalidate()
    }

    /// The sendData delegate will inform if a send event occurred by the async socket.
    public func sendData(sendable: ChatSendable) {
        guard let config = config else { return }
        let chatMessage = SendChatMessageVO(req: sendable, token: config.token, typeCode: config.typeCode)
        addToQueue(sendable: sendable)
        sendToAsync(asyncMessage: AsyncChatServerMessage(chatMessage: chatMessage))
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
                _ = queueTimer.scheduledTimer(withTimeInterval: interval + 2, repeats: false) { [weak self] _ in
                    self?.sendData(sendable: sendable)
                }
            }
            interval += 2
        }
    }

    func sendToAsync(asyncMessage: AsyncSnedable) {
        guard let config = config, let content = asyncMessage.content else { return }
        let asyncMessage = SendAsyncMessageVO(content: content,
                                              ttl: config.msgTTL,
                                              peerName: asyncMessage.peerName ?? config.asyncConfig.serverName,
                                              priority: config.msgPriority,
                                              pushMsgType: asyncMessage.asyncMessageType)
        guard let data = try? JSONEncoder().encode(asyncMessage) else { return }
        logger?.log(title: "send Message", jsonString: asyncMessage.string ?? "", receive: false)
        asyncClient?.sendData(type: .message, data: data)
    }

    /// A timer that repeats ping the `Chat server` every 20 seconds.
    internal func sendPingTimer() {
        pingTimer.invalidate()
        pingTimer = pingTimer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
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
        chat.prepareToSendAsync(req: req)
    }
}
