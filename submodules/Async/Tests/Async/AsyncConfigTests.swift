//
// AsyncConfigTests.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
import XCTest
import Logger
@testable import Async

final class AsyncConfigTests: XCTestCase {
    private var sut: AsyncConfig!
    private var socketAddress = "wss://msg.pod.ir/ws"
    private var peerName = "chat-server"
    private var reconnectOnClose = true
    private var maxRetryCount = Int.max
    private var peerId: Int?
    private var messageTTL = 1000
    private var connectionRetryInterval: TimeInterval = 5
    private var connectionCheckTimeout: TimeInterval = 5
    private var deviceId = ""

    private let logServerURL = "http://10.56.34.61:8080/1m-http-server-test-chat"
    private let logServerMethod = "PUT"
    private let persistLogsOnServer = true
    private let isDebuggingLogEnabled = true
    private let logServerRequestheaders = ["Authorization": "Basic Y2hhdDpjaGF0MTIz", "Content-Type": "application/json"]
    private let prefix = "ASYNC_SDK"

    override func setUpWithError() throws {
        try generateSUTConfig()
    }

    private func generateSUTConfig() throws {
        let asyncLoggerConfig = LoggerConfig(prefix: prefix,
                                             logServerURL: logServerURL,
                                             logServerMethod: logServerURL,
                                             persistLogsOnServer: persistLogsOnServer,
                                             isDebuggingLogEnabled: isDebuggingLogEnabled,
                                             logServerRequestheaders: logServerRequestheaders)

        sut = try AsyncConfigBuilder()
            .socketAddress(socketAddress)
            .reconnectCount(maxRetryCount)
            .reconnectOnClose(reconnectOnClose)
            .connectionRetryInterval(connectionRetryInterval)
            .connectionCheckTimeout(connectionCheckTimeout)
            .appId(appId)
            .peerId(peerId)
            .messageTtl(messageTTL)
            .peerName(peerName)
            .pingInterval(10)
            .loggerConfig(asyncLoggerConfig)
            .deviceId(deviceId)
            .build()
    }

    func test_websocketAddressDoesNotStartWithWss_throw() throws {
        // Given
        socketAddress = "http://www.google.com"

        // Then
        XCTAssertThrowsError(try generateSUTConfig(), "Expected to throw an Error when the server socket address is not start with wss://.") { error in
            if let error = error as? AsyncError, error.code != AsyncErrorCodes.socketAddressShouldStartWithWSS {
                XCTFail("Expected to receive an error with code socketAddressShouldStartWithWSS but received: \(error.code)")
            }
        }
    }

    func test_defaultValues() throws {
        // Given
        sut = try AsyncConfigBuilder().socketAddress(socketAddress).build()

        // Then
        XCTAssertEqual(sut.reconnectCount, 5, "Expected the default value for reconnect count to be equal to 5 but it's \(sut.reconnectCount)")
        XCTAssertEqual(sut.reconnectOnClose, false, "Expected the default value for reconnect on close to be equal to true but it's \(sut.reconnectOnClose)")
        XCTAssertEqual(sut.connectionRetryInterval, 5, "Expected the default value for connectionRetryInterva to be equal to 5 but it's \(sut.connectionRetryInterval)")
        XCTAssertEqual(sut.connectionCheckTimeout, 20, "Expected the default value for connectionCheckTimeout to be equal to 20 but it's \(sut.connectionCheckTimeout)")
        XCTAssertNotEqual(sut.deviceId, "", "Expected the default value for deviceId not to be equal to \"\" but it's \(sut.deviceId)")
        XCTAssertEqual(sut.messageTtl, 10000, "Expected the default value for messageTtl to be equal to 10000 but it's \(sut.messageTtl)")
        XCTAssertEqual(sut.pingInterval, 10, "Expected the default value for pingInterval to be equal to 10 but it's \(sut.pingInterval)")

        // LoggerConfig
        XCTAssertEqual(sut.loggerConfig.logServerMethod, "POST", "Expected the default value for logServerMethod not to be equal to POST but it's \(sut.loggerConfig.logServerMethod)")
        XCTAssertEqual(sut.loggerConfig.prefix, prefix, "Expected the default value for prefix not to be equal to CHAT_SDK but it's \(String(describing: sut.loggerConfig.prefix))")
        XCTAssertNil(sut.loggerConfig.logServerURL, "Expected the default value for logServerURL not to be equal to \(logServerURL) but it's \(String(describing: sut.loggerConfig.logServerURL))")
        XCTAssertFalse(sut.loggerConfig.isDebuggingLogEnabled, "Expected the default value for isDebuggingLogEnabled not to be equal to false but it's \(String(describing: sut.loggerConfig.isDebuggingLogEnabled))")
        XCTAssertFalse(sut.loggerConfig.persistLogsOnServer, "Expected the default value for persistLogsOnServer not to be equal to false but it's \(String(describing: sut.loggerConfig.persistLogsOnServer))")
        XCTAssertEqual(sut.loggerConfig.sendLogInterval, TimeInterval(60), "Expected the default value for sendLogInterval not to be equal to 60 seconds but it's \(String(describing: sut.loggerConfig.sendLogInterval))")
        XCTAssertEqual(sut.loggerConfig.logServerRequestheaders.count, 0, "Expected the default value for logServerRequestheaders not to be equal to be an empty dictionary seconds but it's \(String(describing: sut.loggerConfig.logServerRequestheaders))")
    }

    func test_setPeerId() throws {
        // Given
        peerId = 1
        // When
        try generateSUTConfig()
        // Then
        XCTAssertEqual(sut.peerId, 1)
    }

    func test_setMessageTTL() throws {
        // Given
        messageTTL = 5000
        // When
        try generateSUTConfig()
        // Then
        XCTAssertEqual(sut.messageTtl, 5000)
    }

    func test_setConnectionRetryInterval() throws {
        // Given
        connectionRetryInterval = 5
        // When
        try generateSUTConfig()
        // Then
        XCTAssertEqual(sut.connectionRetryInterval, 5)
    }

    func test_setConnectionCheckTimeout() throws {
        // Given
        connectionCheckTimeout = 5
        // When
        try generateSUTConfig()
        // Then
        XCTAssertEqual(sut.connectionCheckTimeout, 5)
    }

    func test_setDeviceId() throws {
        // Given
        deviceId = "TEST"
        // When
        try generateSUTConfig()
        // Then
        XCTAssertEqual(sut.deviceId, "TEST")
    }

    func test_updateDeviceId() throws {
        // Given
        deviceId = "TEST"
        // When
        try generateSUTConfig()
        sut.updateDeviceId("UPDATED_DEVICE_ID")
        // Then
        XCTAssertEqual(sut.deviceId, "UPDATED_DEVICE_ID")
    }
}
