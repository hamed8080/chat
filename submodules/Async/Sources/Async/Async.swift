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
@AsyncGlobalActor
public final class Async: AsyncInternalProtocol, WebSocketProviderDelegate {
    public weak var delegate: AsyncDelegate?
    var config: AsyncConfig
    var socket: WebSocketProvider
    var stateModel: AsyncStateModel = .init()
    var logger: Logger
    var deviceInfo: DeviceInfo?
    private var isDisposed: Bool = false
    private let pingManager: AsyncPingManager
    private let reconnctManager: AsyncReconnectManager?
    private var networkObserver = NetworkAvailabilityFactory.create()
    private var debug = ProcessInfo().environment["ENABLE_ASYNC_LOGGING"] == "1"

    /// The initializer of async.
    ///
    /// After creating this object you should call ``Async/connect()`` to start connecting to the server unless it's not connected automatically.
    /// - Parameters:
    ///   - socket: A socket provider.
    ///   - config: Configuration of async ``AsyncConfig``.
    ///   - delegate: Delegate to notify events.
    ///   - logger: A logger instance to log events.
    public init(socket: WebSocketProvider, config: AsyncConfig, delegate: AsyncDelegate? = nil, logger: Logger) async {
        self.logger = logger
        logger.delegate = delegate
        self.config = config
        self.delegate = delegate
        self.socket = socket
        self.pingManager = AsyncPingManager(pingInterval: config.pingInterval, logger: logger)
        if config.reconnectOnClose == true {
            self.reconnctManager = AsyncReconnectManager(maxReconnect: config.reconnectCount, logger: logger)
        } else {
            self.reconnctManager = nil
        }
        self.socket.delegate = self
        await setDeviceInfo()
        await setupObservers()
    }

    private func setupObservers() async {
        await setupOnSceneBecomeActiveObserver()
        networkObserver.onNetworkChange = { [weak self] isConnected in
            Task { @AsyncGlobalActor [weak self] in
                guard let self = self else { return }
                if isConnected {
                    self.reconnctManager?.resetAndStop()
                    self.reconnect()
                } else {
                    self.onDisconnected(self.socket, NSError(domain: "There is no active connection status interface.", code: NSURLErrorCancelled))
                }
            }
        }
        
        pingManager.callback = { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                onDisconnected(self.socket, error)
            } else {
                sendPing()
            }
        }
        
        reconnctManager?.callback = { [weak self] error in
            guard let self = self else { return }
            if error == nil, isDisposed == false && stateModel.socketState != .connected {
                reconnect()
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
        pingManager.stopPingTimers()
        let code = (error as? NSError)?.code
        let connectImmediately =  code == 53 || code == 89
        if connectImmediately {
            logger.log(message: "Connect immediately", persist: false, type: .internalLog)
        }
        reconnctManager?.restart(duration: connectImmediately ? 0 : config.connectionRetryInterval)
    }

    public func onReceivedError(_ error: Error?) {}

    public func onReceivedData(_: WebSocketProvider, didReceive data: Data) {
        pingManager.reschedule()
        messageReceived(data: data)
    }

    private func socketConnected() {
        log("socketConnected called")
        reconnctManager?.resetAndStop()
    }

    /// Send data to server.
    ///
    ///  The message will send only if the socket state is in ``AsyncSocketState/asyncReady`` mode unless the message will be queued and after connecting to the server it sends those messages.
    /// - Parameters:
    ///   - message: A sendable async message, at end it will convert to ``AsyncMessage`` and then data.
    ///   - type: The type of async message. For most of the times it will use ``AsyncMessageTypes/message``.
    public func send(message: SendAsyncMessageVO, type: AsyncMessageTypes = .message) {
        log("send called")
        guard let data = try? JSONEncoder.instance.encode(message) else { return }
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
        let asyncSendMessage = AsyncMessage(content: data?.utf8String, type: type)
        let asyncMessageData = try? JSONEncoder.instance.encode(asyncSendMessage)
        logger.logJSON(title: "Send an internal message", jsonString: asyncSendMessage.string ?? "", persist: false, type: .sent, userInfo: ["\(type.rawValue)": asyncSendMessage.string ?? ""])
        guard let asyncMessageData = asyncMessageData, let string = String(data: asyncMessageData, encoding: .utf8) else { return }
        socket.send(text: string)
    }

    /// Dispose and try to disconnect immediately and release all related objects.
    public func disposeObject() {
        log("disposeObject called")
        pingManager.stopPingTimers()
        reconnctManager?.resetAndStop()
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
@AsyncGlobalActor
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

    @MainActor
    private func setupOnSceneBecomeActiveObserver() {
#if canImport(UIKit)
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(onSceneBeomeActive(_:)), name: UIScene.willEnterForegroundNotification, object: nil)
        }
#endif
    }

    @available(iOS 13.0, *)
    @MainActor
    @objc func onSceneBeomeActive(_: Notification) {
        Task { @AsyncGlobalActor [weak self] in
            self?.onSceneBecomeActive()
        }
    }
    
    @available(iOS 13.0, *)
    private func onSceneBecomeActive() {
        logger.log(message: "onSceneBeomeActive called in Async with deviceId:\(stateModel.deviceId ?? "nil") socketState:\(stateModel.socketState)", persist: false, type: .internalLog)
        if stateModel.deviceId != nil, stateModel.socketState == .closed {
            logger.log(message: "onSceneBeomeActive restart reconnect timer", persist: false, type: .internalLog)
            reconnctManager?.restart(duration: 0)
        }
    }
}
