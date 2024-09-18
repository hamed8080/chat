//
// AsyncManager.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 12/16/22

import Additive
import Async
import ChatCore
import ChatDTO
import ChatModels
import Foundation
import Logger

private struct QueueableWithType {
    let queueable: Queueable
    let type: ChatMessageVOTypes
}

/// AsyncManager intermediate between chat and async socket server.
public final class AsyncManager: AsyncDelegate {
    private var config: ChatConfig? { chat?.config }
    private var logger: Logger? { chat?.logger }
    var chat: ChatInternalProtocol?
    /// Async client.
    public var asyncClient: Async?

    private var serialQueue = DispatchQueue(label: "CHAT_ASYNC_MANAGER_QUEUE", qos: .utility)
    /// A timer to check the connection status every 20 seconds.
    private(set) var pingTimer: SourceTimer
    private(set) var queueTimer: SourceTimer

    /// This queue will live till application is running and this class is in memory, be careful it's not persistent on storage.
    private var queue: [String: QueueableWithType] = [:]

    /// This saves all requests that need to use pagination and later calculates whether it has the next item or not. The key is uniqueId and the value is count.
    /// Because if we have count we can estimate that  a response is at the end or not.
    private var paginateables: [String: (count: Int, offset: Int)] = [:]

    public init(pingTimer: SourceTimer, queueTimer: SourceTimer) {
        self.pingTimer = pingTimer
        self.queueTimer = queueTimer
    }

    /// Create an async connection.
    public func createAsync() {
        if let asyncConfig = config?.asyncConfig {
            asyncClient = SocketFactory.create(config: asyncConfig, delegate: self)
            asyncClient?.connect()
        }
    }

    /// A delegate method that receives a message.
    public func asyncMessage(asyncMessage: AsyncMessage) {
        serialQueue.asyncWork { [weak self] in
            guard let self = self else { return }
            chat?.invokeCallback(asyncMessage: asyncMessage)
            schedulePingTimer()
            if let ban = asyncMessage.banError {
                scheduleForResendQueues(ban)
            } else {
                removeFromQueue(asyncMessage: asyncMessage)
            }
        }
    }

    /// A delegate that tells the status of the async connection.
    public func asyncStateChanged(asyncState: AsyncSocketState, error: AsyncError?) {
        (chat as? ChatImplementation)?.state = asyncState.chatState
        chat?.delegate?.chatState(state: asyncState.chatState, currentUser: nil, error: error?.chatError)
        if asyncState == .asyncReady {
            (chat?.user as? UserManager)?.getUserForChatReady()
            // In the first time it won't clear the cache due to the all managers are null.
            chat?.cache?.truncate()
        } else if asyncState == .closed {
            cancelPingTimer()
            logger?.createLog(message: "Socket Disconnected", persist: false, level: LogLevel.error, type: .received)
            chat?.coordinator.invalidate()
        }
    }

    /// It will be only used whenever a client implements a custom async class by itself.
    public func asyncMessageSent(message _: Data?, error _: AsyncError?) {}

    /// A delegate to raise an error.
    public func asyncError(error: AsyncError) {
        let chatError = ChatError(type: .asyncError, message: error.message, userInfo: error.userInfo, rawError: error.rawError)
        let errorResponse = ChatResponse(result: Any?.none, error: chatError, typeCode: nil)
        chat?.delegate?.chatEvent(event: .system(.error(errorResponse)))
    }

    /// A public method to completely destroy the async object.
    public func disposeObject() {
        asyncClient?.disposeObject()
        asyncClient = nil
        cancelPingTimer()
        queueTimer.cancel()
    }

    /// The sendData delegate will inform if a send event occurred by the async socket.
    public func sendData(sendable: ChatSendable, type: ChatMessageVOTypes) {
        serialQueue.asyncWork { [weak self] in
            guard let self = self else { return }
            guard let config = config else { return }
            let typeCodeIndex = sendable.chatTypeCodeIndex
            guard config.typeCodes.indices.contains(typeCodeIndex) else { fatalError("Type code index is not exist. Check if the index of the type is right.") }
            let ownerTypeCode = config.typeCodes[typeCodeIndex]
            let chatMessage = SendChatMessageVO(req: sendable, type: type.rawValue, token: config.token, typeCode: ownerTypeCode.typeCode, ownerId: ownerTypeCode.ownerId)
            addToQueue(sendable: sendable, type: type)
            addToPaginateable(sendable: sendable)
            sendToAsync(asyncMessage: AsyncChatServerMessage(chatMessage: chatMessage), type: type)
        }
    }

    private func addToQueue(sendable: ChatSendable, type: ChatMessageVOTypes) {
        if config?.enableQueue == true, let queueable = sendable as? Queueable {
            queue[sendable.chatUniqueId] = .init(queueable: queueable, type: type)
        }
    }

    private func removeFromQueue(asyncMessage: AsyncMessage) {
        if let uniqueId = SendChatMessageVO(with: asyncMessage)?.uniqueId, queue[uniqueId] != nil {
            queue.removeValue(forKey: uniqueId)
        }
        removeForwardMessagesQueue(asyncMessage)
    }

    /// For forward messages, we have to check an array of uniqueIds instead of a single uniqueId.
    func removeForwardMessagesQueue(_ asyncMessage: AsyncMessage) {
        if let chatMessage = SendChatMessageVO(with: asyncMessage),
           chatMessage.type == ChatMessageVOTypes.sent.rawValue,
           let forwardUniqueIds = queue.first(where: {$0.key.contains(chatMessage.uniqueId ?? "")})?.key {
            queue.removeValue(forKey: forwardUniqueIds)
        }
    }

    public func pop(_ uniqueId: String?) -> (count: Int, offset: Int)? {
        guard let uniqueId = uniqueId else { return nil }
        let value = paginateables[uniqueId]
        paginateables.removeValue(forKey: uniqueId)
        return value
    }

    private func addToPaginateable(sendable: ChatSendable) {
        if let paginateable = sendable as? Paginateable {
            let offset = paginateable.offset == -1 ? 0 : paginateable.offset
            paginateables[paginateable.uniqueId] = (count: paginateable.count, offset: offset)
        }
    }

    private func removeFromPaginateable(paginateable: Paginateable) {
        if paginateables[paginateable.uniqueId] != nil {
            paginateables.removeValue(forKey: paginateable.uniqueId)
        }
    }

    /// Send queueable each one by one after ``ChatState.chatReady`` with 2 seconds interval between each message to prevent server rejection.
    func sendQueuesOnReconnect() {
        var interval: TimeInterval = 0
        queue.sorted { $0.value.queueable.queueTime < $1.value.queueable.queueTime }.forEach { _, item in
            if let sendable = item.queueable as? ChatSendable {
                queueTimer = SourceTimer()
                queueTimer.start(duration: interval + 2) { [weak self] in
                    self?.sendData(sendable: sendable, type: item.type)
                }
            }
            interval += 2
        }
    }

    func sendToAsync(asyncMessage: AsyncSnedable, type: ChatMessageVOTypes) {
        guard let config = config, let content = asyncMessage.content else { return }
        let asyncMessage = SendAsyncMessageVO(content: content,
                                              ttl: config.msgTTL,
                                              peerName: asyncMessage.peerName ?? config.asyncConfig.peerName,
                                              priority: config.msgPriority,
                                              uniqueId: (asyncMessage as? AsyncChatServerMessage)?.chatMessage.uniqueId)
        guard chat?.state == .chatReady || chat?.state == .asyncReady else { return }
        logger?.logJSON(title: "send Message with type: \(type)", jsonString: asyncMessage.string ?? "", persist: false, type: .sent)
        asyncClient?.send(message: asyncMessage)
    }

    /// A timer that repeats ping the `Chat server` every 20 seconds.
    internal func schedulePingTimer() {
        cancelPingTimer()
        pingTimer = SourceTimer()
        pingTimer.start(duration: 20){ [weak self] in
            guard let self = self else { return }
            sendChatServerPing()
        }
    }

    /// It's different from ping in async SDK you need to send a ping to the chat server to keep peerId
    /// If you don't send a ping to the chat server it clears peerId within the 30s to 1 minute and the chat server cannot send messages to the client like new chat inside the thread
    private func sendChatServerPing() {
        let req = BareChatSendableRequest()
        sendData(sendable: req, type: .ping)
    }

    /// When a user rapidly sends an action to the Async server, they'll be banned by Async Server.
    /// Due to this matter, we should reschedule a timer to start sending all messages inside the queue.
    private func scheduleForResendQueues(_ ban: BanError) {
        chat?.banTimer.scheduledTimer(interval: TimeInterval((ban.duration ?? 5000) / 1000) + 1, repeats: false) { [weak self] _ in
            self?.sendQueuesOnReconnect()
        }
    }

    /// On Async SDK log. It is needed for times that client applications need to collect logs of the async SDK.
    public func onLog(log: Log) {
        logger?.delegate?.onLog(log: log)
    }

    private func cancelPingTimer() {
        pingTimer.cancel()
    }
}
