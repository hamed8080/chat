//
// AsyncManager.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import FanapPodAsyncSDK
import Foundation

/// AsyncManager intermediate between chat and async socket server.
internal class AsyncManager: AsyncDelegate {
    /// Async client.
    private(set) var asyncClient: Async?

    /// Last message date that was received from the server to manage ping status.
    private var lastSentMessageDate: Date? = Date()

    /// A timer to check the connection status every 20 seconds.
    private(set) var chatServerPingTimer: Timer?

    public init() {}

    /// Create an async connection.
    public func createAsync() {
        if let asyncConfig = Chat.sharedInstance.config?.asyncConfig {
            asyncClient = Async(config: asyncConfig, delegate: self)
            asyncClient?.createSocket()
        }
    }

    /// A delegate method that receives a message.
    public func asyncMessage(asyncMessage: AsyncMessage) {
        ReceiveMessageFactory.invokeCallback(asyncMessage: asyncMessage)
    }

    /// A delegate that tells the status of the async connection.
    public func asyncStateChanged(asyncState: AsyncSocketState, error: AsyncError?) {
        Chat.sharedInstance.delegate?.chatState(state: asyncState.chatState, currentUser: nil, error: error?.chatError)
        if asyncState == .ASYNC_READY {
            UserInfoRequestHandler.getUserForChatReady()
        } else if asyncState == .CLOSED {
            chatServerPingTimer?.invalidate()
        }
    }

    /// It will be only used whenever a client implements a custom async class by itself.
    public func asyncMessageSent(message _: Data) {}

    /// A delegate to raise an error.
    public func asyncError(error: AsyncError) {
        Chat.sharedInstance.delegate?.chatError(error: .init(code: .asyncError, message: error.message, userInfo: error.userInfo, rawError: error.rawError))
    }

    /// A public method to completely destroy the async object.
    public func disposeObject() {
        asyncClient?.disposeObject()
        asyncClient = nil
        chatServerPingTimer?.invalidate()
        chatServerPingTimer = nil
    }

    /// The sendData delegate will inform if a send event occurred by the async socket.
    public func sendData(type: AsyncMessageTypes, data: Data) {
        asyncClient?.sendData(type: type, data: data)
        sendPingTimer()
    }

    /// A timer that repeats ping the `Chat server` every 20 seconds.
    internal func sendPingTimer() {
        chatServerPingTimer?.invalidate()
        chatServerPingTimer = nil
        chatServerPingTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if let lastSentMessageDate = self.lastSentMessageDate, Date().timeIntervalSince1970 - (lastSentMessageDate.timeIntervalSince1970 + 20) > 20 {
                self.sendChatServerPing()
            }
        }
    }

    /// It's different from ping in async SDK you need to send a ping to the chat server to keep peerId
    /// If you don't send a ping to the chat server it clears peerId within the 30s to 1 minute and the chat server cannot send messages to the client like new chat inside the thread
    private func sendChatServerPing() {
        Chat.sharedInstance.prepareToSendAsync(messageType: .ping)
    }
}
