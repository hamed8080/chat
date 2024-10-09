//
// AsyncConfig.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
import Logger

/// Configuration data that needs to prepare to use SDK.
///
/// To work with SDK this struct must be passed to ``Async`` initializer.
public struct AsyncConfig: Codable {
    public private(set) var socketAddress: String
    public private(set) var peerName: String
    public private(set) var deviceId: String = UUID().uuidString
    public private(set) var appId: String = "POD-Chat"
    public private(set) var peerId: Int?
    public private(set) var messageTtl: Int = 10000
    public private(set) var pingInterval: TimeInterval = 10
    public private(set) var connectionRetryInterval: TimeInterval = 5
    public private(set) var connectionCheckTimeout: TimeInterval = 20
    public private(set) var reconnectCount: Int = 5
    public private(set) var reconnectOnClose: Bool = false
    public private(set) var loggerConfig: LoggerConfig

    /// Configuration data that needs to prepare to use SDK.
    ///
    /// - Parameters:
    ///   - socketAddress: The server address of socket.
    ///   - peerName: The peer name of the destination server.
    ///   - deviceId: Device id of the current device if you don't pass an id it generates an id with UUID.
    ///   - appId: The id of application that registered in server.
    ///   - peerId: Id of peer.
    ///   - messageTtl: Message TTL.
    ///   - connectionRetryInterval: The interval between fails to connect tries.
    ///   - connectionCheckTimeout: Time in seconds for checking connection status and try if disconnected or informing you through the delegate.
    ///   - reconnectCount: The amount of times when socket fail or disconnect if reconnectOnClose is enabled
    ///   - reconnectOnClose: If it is true it tries to connect again depending on how many times you've set reconnectCount.
    public init(socketAddress: String,
                peerName: String,
                deviceId: String = UUID().uuidString,
                appId: String = "POD-Chat",
                loggerConfig: LoggerConfig = LoggerConfig(prefix: "ASYNC_SDK"),
                peerId: Int? = nil,
                messageTtl: Int = 10000,
                pingInterval: TimeInterval = 10,
                connectionRetryInterval: TimeInterval = 5,
                connectionCheckTimeout: TimeInterval = 20,
                reconnectCount: Int = 5,
                reconnectOnClose: Bool = false)
        throws
    {
        try self.init(socketAddress: socketAddress, peerName: peerName, appId: appId, loggerConfig: loggerConfig)
        self.deviceId = deviceId
        self.peerId = peerId
        self.messageTtl = messageTtl
        self.pingInterval = pingInterval
        self.connectionRetryInterval = connectionRetryInterval
        self.connectionCheckTimeout = connectionCheckTimeout
        self.reconnectCount = reconnectCount
        self.reconnectOnClose = reconnectOnClose
    }

    /// Configuration data that needs to prepare to use SDK.
    ///
    /// - Parameters:
    ///   - socketAddress: The server address of socket.
    ///   - peerName: The peer name of the destination server.
    ///   - appId: The id of application that registered in server.
    ///   - loggerConfig: The id of application that registered in server.
    public init(socketAddress: String, peerName: String, appId: String, loggerConfig: LoggerConfig) throws {
        if !(socketAddress.contains("wss://") || socketAddress.contains("ws://")) {
            throw AsyncError(code: .socketAddressShouldStartWithWSS, message: "Async socket address should start with wss")
        }
        self.socketAddress = socketAddress
        self.peerName = peerName
        self.appId = appId
        self.loggerConfig = loggerConfig
    }

    public mutating func updateDeviceId(_ deviceId: String) {
        self.deviceId = deviceId
    }
}

public final class AsyncConfigBuilder {
    private(set) var socketAddress: String = ""
    private(set) var peerName: String = ""
    private(set) var deviceId: String = UUID().uuidString
    private(set) var appId: String = "POD-Chat"
    private(set) var peerId: Int?
    private(set) var messageTtl: Int = 10000
    private(set) var pingInterval: TimeInterval = 10
    private(set) var connectionRetryInterval: TimeInterval = 5
    private(set) var connectionCheckTimeout: TimeInterval = 20
    private(set) var reconnectCount: Int = 5
    private(set) var reconnectOnClose: Bool = false
    private(set) var loggerConfig: LoggerConfig = .init(prefix: "ASYNC_SDK")
    public init() {}

    @discardableResult
    public func socketAddress(_ socketAddress: String) -> AsyncConfigBuilder {
        self.socketAddress = socketAddress
        return self
    }

    @discardableResult
    public func peerName(_ peerName: String) -> AsyncConfigBuilder {
        self.peerName = peerName
        return self
    }

    @discardableResult
    public func deviceId(_ deviceId: String) -> AsyncConfigBuilder {
        self.deviceId = deviceId
        return self
    }

    @discardableResult
    public func appId(_ appId: String) -> AsyncConfigBuilder {
        self.appId = appId
        return self
    }

    @discardableResult
    public func peerId(_ peerId: Int?) -> AsyncConfigBuilder {
        self.peerId = peerId
        return self
    }

    @discardableResult
    public func messageTtl(_ messageTtl: Int) -> AsyncConfigBuilder {
        self.messageTtl = messageTtl
        return self
    }

    @discardableResult
    public func connectionRetryInterval(_ connectionRetryInterval: TimeInterval) -> AsyncConfigBuilder {
        self.connectionRetryInterval = connectionRetryInterval
        return self
    }

    @discardableResult
    public func pingInterval(_ pingInterval: TimeInterval) -> AsyncConfigBuilder {
        self.pingInterval = pingInterval
        return self
    }

    @discardableResult
    public func connectionCheckTimeout(_ connectionCheckTimeout: TimeInterval) -> AsyncConfigBuilder {
        self.connectionCheckTimeout = connectionCheckTimeout
        return self
    }

    @discardableResult
    public func reconnectCount(_ reconnectCount: Int) -> AsyncConfigBuilder {
        self.reconnectCount = reconnectCount
        return self
    }

    @discardableResult
    public func reconnectOnClose(_ reconnectOnClose: Bool) -> AsyncConfigBuilder {
        self.reconnectOnClose = reconnectOnClose
        return self
    }

    @discardableResult
    public func loggerConfig(_ loggerConfig: LoggerConfig) -> AsyncConfigBuilder {
        self.loggerConfig = loggerConfig
        return self
    }

    public func build() throws -> AsyncConfig {
        try AsyncConfig(socketAddress: socketAddress,
                        peerName: peerName,
                        deviceId: deviceId,
                        appId: appId,
                        loggerConfig: loggerConfig,
                        peerId: peerId,
                        messageTtl: messageTtl,
                        pingInterval: pingInterval,
                        connectionRetryInterval: connectionRetryInterval,
                        connectionCheckTimeout: connectionCheckTimeout,
                        reconnectCount: reconnectCount,
                        reconnectOnClose: reconnectOnClose)
    }
}
