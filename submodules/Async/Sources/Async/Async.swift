//
// Async.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Additive
import Foundation
import Logger
#if canImport(UIKit)
import UIKit
#endif

/// It will connect through Apple native socket in iOS 13 and above, unless it will connect through StarScream in older devices.
public final class Async: AsyncInternalProtocol, WebSocketProviderDelegate {
    public weak var delegate: AsyncDelegate?
    var config: AsyncConfig
    var socket: WebSocketProvider
    var queue: DispatchQueueProtocol
    var stateModel: AsyncStateModel = .init()
    var reconnectTimer: SourceTimer?
    var pingTimerFirst: SourceTimer?
    var pingTimerSecond: SourceTimer?
    var pingTimerThird: SourceTimer?
    var logger: Logger
    var isDisposed: Bool = false
    private var networkObserver = NetworkAvailabilityFactory.create()
    private var debug = ProcessInfo().environment["talk.pod.ir.async.debug"] == "1"

    /// The initializer of async.
    ///
    /// After creating this object you should call ``Async/Async/connect()`` to start connecting to the server unless it's not connected automatically.
    /// - Parameters:
    ///   - socket: A socket provider.
    ///   - config: Configuration of async ``AsyncConfig``.
    ///   - delegate: Delegate to notify events.
    ///   - queue: A queue in which respones back.
    public init(socket: WebSocketProvider, config: AsyncConfig, delegate: AsyncDelegate? = nil, logger: Logger, queue: DispatchQueueProtocol = DispatchQueue(label: "ASYNC_QUEUE")) {
        self.logger = logger
        logger.delegate = delegate
        self.config = config
        self.delegate = delegate
        self.socket = socket
        self.queue = queue
        self.socket.delegate = self
        setupObservers()
    }

    private func setupObservers() {
        setupOnSceneBecomeActiveObserver()
        networkObserver.onNetworkChange = { [weak self] isConnected in
            guard let self = self else { return }
            if isConnected {
                stopReconnectTimer()
                reconnect()
            } else {
                onDisconnected(self.socket, NSError(domain: "There is no active connection status interface.", code: NSURLErrorCancelled))
            }
        }
    }

    public func recreate() {
        socket = type(of: socket).init(url: URL(string: config.socketAddress)!, timeout: config.connectionRetryInterval, logger: logger)
        isDisposed = false
    }

    /// Connect to async server.
    public func connect() {
        onStatusChanged(.connecting)
        socket.connect()
    }

    /// Reconnect when you want to connect again.
    public func reconnect() {
        connect()
    }

    public func onConnected(_: WebSocketProvider) {
        log("onConnected called")
        onStatusChanged(.connected)
        socketConnected()
    }

    public func onDisconnected(_: WebSocketProvider, _ error: Error?) {
        log("onDisconnected called")
        stateModel.isDeviceRegistered = false
        logger.log(message: "Disconnected with error:\(String(describing: error))", persist: false, type: .internalLog)
        onStatusChanged(.closed, error)
        queue.asyncWork { [weak self] in
            guard let self = self else { return }
            stopPingTimers()
            stopReconnectTimer()
            let connectImmediately = (error as? NSError)?.code == 53
            if connectImmediately {
                logger.log(message: "Connect immediately", persist: false, type: .internalLog)
            }
            restartReconnectTimer(duration: connectImmediately ? 0 : config.connectionRetryInterval)
        }
    }

    public func onReceivedError(_ error: Error?) {}

    public func onReceivedData(_: WebSocketProvider, didReceive data: Data) {
        queue.asyncWork { [weak self] in
            self?.schedulePingTimers()
            self?.messageReceived(data: data)
        }
    }

    private func schedulePingTimers() {
        log("schedulePingTimers called")
        stopPingTimers()
        scheduleFirstTimer()
        scheduleSecondTimer()
        scheduleThirdTimer()
    }

    private func scheduleFirstTimer() {
        log("scheduleFirstTimer called")
        pingTimerFirst = SourceTimer()
        pingTimerFirst?.start(duration: config.pingInterval) { [weak self] in
            guard let self = self else { return }
            sendPing()
        }
    }

    private func scheduleSecondTimer() {
        log("scheduleSecondTimer called")
        pingTimerSecond = SourceTimer()
        pingTimerSecond?.start(duration: config.pingInterval + 3) { [weak self] in
            guard let self = self else { return }
            sendPing()
        }
    }

    private func scheduleThirdTimer() {
        log("scheduleThirdTimer called")
        pingTimerThird = SourceTimer()
        pingTimerThird?.start(duration: config.pingInterval + 3 + 2){ [weak self] in
            guard let self = self else { return }
            let error = NSError(domain: "Failed to retrieve a ping from the Async server.", code: NSURLErrorCannotConnectToHost)
            self.onDisconnected(self.socket, error)
        }
    }

    private func socketConnected() {
        log("socketConnected called")
        stateModel.retryCount = 0
        stopReconnectTimer()
    }

    private func restartReconnectTimer(duration: TimeInterval) {
        log("restartReconnectTimer called")
        if config.reconnectOnClose == true && reconnectTimer == nil {
            reconnectTimer = SourceTimer()
            reconnectTimer?.start(duration: duration){ [weak self] in
                guard let self = self else { return }
                log("restartReconnectTimer closufre called")
                if isDisposed == false && stateModel.socketState != .connected {
                    tryReconnect()
                }
            }
        }
    }

    public func stopPingTimers() {
        log("stopPingTimers called")
        pingTimerFirst?.cancel()
        pingTimerFirst = nil
        pingTimerSecond?.cancel()
        pingTimerSecond = nil
        pingTimerThird?.cancel()
        pingTimerThird = nil
    }

    public func stopReconnectTimer() {
        log("stopReconnectTimer called")
        reconnectTimer?.cancel()
        reconnectTimer = nil
    }

    private func tryReconnect() {
        log("tryReconnect called")
        if stateModel.retryCount < config.reconnectCount {
            stateModel.retryCount += 1
            logger.log(message: "Try reconnect for \(stateModel.retryCount) times", persist: false, type: .internalLog)
            reconnect()
        } else {
            logger.log(message: "Failed to reconnect after \(config.reconnectCount) tries", persist: false, type: .internalLog)
            stopReconnectTimer()
        }
    }

    /// Send data to server.
    ///
    ///  The message will send only if the socket state is in ``AsyncSocketState/asyncReady`` mode unless the message will be queued and after connecting to the server it sends those messages.
    /// - Parameters:
    ///   - message: A sendable async message, at end it will convert to ``AsyncMessage`` and then data.
    ///   - type: The type of async message. For most of the times it will use ``AsyncMessageTypes/message``.
    public func send(message: SendAsyncMessageVO, type: AsyncMessageTypes = .message) {
        log("send called")
        queue.asyncWork { [weak self] in
            guard let self = self, let data = try? JSONEncoder.instance.encode(message) else { return }
            log("send queue called")
            let asyncSendMessage = AsyncMessage(content: data.utf8String, type: type)
            let asyncMessageData = try? JSONEncoder.instance.encode(asyncSendMessage)
            if stateModel.socketState == .asyncReady {
                guard let asyncMessageData = asyncMessageData, let string = String(data: asyncMessageData, encoding: .utf8) else { return }
                logger.logJSON(title: "Send message", jsonString: asyncSendMessage.string ?? "", persist: false, type: .sent)
                delegate?.asyncMessageSent(message: asyncMessageData, error: nil)
                socket.send(text: string)
            } else {
                delegate?.asyncMessageSent(message: nil, error: AsyncError(code: .socketIsNotConnected))
            }
        }
    }

    /// Notify and close the current connection.
    public func closeConnection() {
        log("closeConnection called")
        onStatusChanged(.closed)
        socket.closeConnection()
    }

    private func registerDevice() {
        log("registerDevice called")
        if let deviceId = stateModel.oldDeviceId ?? stateModel.deviceId {
            let peerId = stateModel.peerId
            let shouldRegister = peerId == nil
            let register: RegisterDevice = shouldRegister ? .init(renew: true, appId: config.appId, deviceId: deviceId) : .init(refresh: true, appId: config.appId, deviceId: deviceId)
            if let data = try? JSONEncoder.instance.encode(register) {
                sendInternalData(type: .deviceRegister, data: data)
            }
        }
    }

    private func registerServer() {
        log("registerServer called")
        let register = RegisterServer(name: config.peerName)
        if let data = try? JSONEncoder.instance.encode(register) {
            sendInternalData(type: .serverRegister, data: data)
        }
    }

    private func sendACK(asyncMessage: AsyncMessage) {
        log("sendACK called")
        if let id = asyncMessage.id {
            let messageACK = MessageACK(messageId: id)
            if let data = try? JSONEncoder.instance.encode(messageACK) {
                sendInternalData(type: .ack, data: data)
            }
        }
    }

    func sendPing() {
        log("sendPing called")
        sendInternalData(type: .ping, data: nil)
    }

    func sendInternalData(type: AsyncMessageTypes, data: Data?) {
        log("sendInternalData called")
        queue.asyncWork { [weak self] in
            guard let self = self else { return }
            let asyncSendMessage = AsyncMessage(content: data?.utf8String, type: type)
            let asyncMessageData = try? JSONEncoder.instance.encode(asyncSendMessage)
            logger.logJSON(title: "Send an internal message", jsonString: asyncSendMessage.string ?? "", persist: false, type: .sent, userInfo: ["\(type.rawValue)": asyncSendMessage.string ?? ""])
            guard let asyncMessageData = asyncMessageData, let string = String(data: asyncMessageData, encoding: .utf8) else { return }
            socket.send(text: string)
        }
    }

    /// Dispose and try to disconnect immediately and release all related objects.
    public func disposeObject() {
        log("disposeObject called")
        stopPingTimers()
        stopReconnectTimer()
        closeConnection()
        delegate = nil
        isDisposed = true
    }

    private func log(_ message: String) {
#if DEBUG
        if debug {
            logger.log(message: message, persist: false, type: .internalLog)
        }
#endif
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// async on Message Received Handler
extension Async {
    private func messageReceived(data: Data) {
        guard let asyncMessage = try? JSONDecoder.instance.decode(AsyncMessage.self, from: data) else {
            logger.log(message: "Can not decode the data", persist: false, type: .internalLog)
            return
        }
        logger.logJSON(title: "On Receive Message", jsonString: asyncMessage.string ?? "", persist: false, type: .received)
        stateModel.setLastMessageReceiveDate()
        switch asyncMessage.type {
        case .ping:
            onPingMessage(asyncMessage: asyncMessage)
        case .serverRegister:
            onServerRegisteredMessage(asyncMessage: asyncMessage)
        case .deviceRegister:
            onDeviceRegisteredMessage(asyncMessage: asyncMessage)
        case .message:
            delegate?.asyncMessage(asyncMessage: asyncMessage)
        case .messageAckNeeded, .messageSenderAckNeeded:
            sendACK(asyncMessage: asyncMessage)
            delegate?.asyncMessage(asyncMessage: asyncMessage)
        case .ack:
            delegate?.asyncMessage(asyncMessage: asyncMessage)
        case .getRegisteredPeers:
            break
        case .peerRemoved, .registerQueue, .notRegistered, .errorMessage:
            break
        case .none:
            logger.createLog(message: "UNKOWN type received", persist: true, level: .error, type: .internalLog, userInfo: loggerUserInfo)
        }
    }

    private func onPingMessage(asyncMessage: AsyncMessage) {
        if asyncMessage.content != nil {
            if stateModel.deviceId == nil || stateModel.deviceId != asyncMessage.content {
                stateModel.setDeviceId(deviceId: asyncMessage.content)
            }
            registerDevice()
        }
    }

    private func onDeviceRegisteredMessage(asyncMessage: AsyncMessage) {
        let oldPeerId = stateModel.peerId
        if let peerIdString = asyncMessage.content {
            stateModel.setPeerId(peerId: Int(peerIdString))
        }

        if stateModel.isServerRegistered == true, stateModel.peerId == oldPeerId {
            onStatusChanged(.asyncReady)
        } else {
            registerServer()
        }

        /// We should set this property after checking if current state is registered or not.
        stateModel.isDeviceRegistered = true
    }

    private func onServerRegisteredMessage(asyncMessage: AsyncMessage) {
        if asyncMessage.senderName == config.peerName {
            stateModel.isServerRegistered = true
            onStatusChanged(.asyncReady)
        } else {
            registerServer()
        }
    }

    func onStatusChanged(_ status: AsyncSocketState, _ error: Error? = nil) {
        stateModel.setSocketState(socketState: status)
        logger.log(message: "Connection State Changed to: \(status)", persist: false, type: .internalLog)
        delegate?.asyncStateChanged(asyncState: status, error: error == nil ? nil : .init(rawError: error))
    }

    private func setupOnSceneBecomeActiveObserver() {
#if canImport(UIKit)
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(onSceneBeomeActive(_:)), name: UIScene.willEnterForegroundNotification, object: nil)
        }
#endif
    }

    @available(iOS 13.0, *)
    @objc func onSceneBeomeActive(_: Notification) {
        logger.log(message: "onSceneBeomeActive called in Async with deviceId:\(stateModel.deviceId ?? "nil") socketState:\(stateModel.socketState)", persist: false, type: .internalLog)
        if stateModel.deviceId != nil, stateModel.socketState == .closed {
            logger.log(message: "onSceneBeomeActive restart reconnect timer", persist: false, type: .internalLog)
            stopReconnectTimer()
            restartReconnectTimer(duration: 0)
        }
    }
}
