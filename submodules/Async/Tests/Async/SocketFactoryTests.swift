//
// SocketFactoryTests.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import XCTest
import Logger
import Mocks
import Additive
@testable import Async

final class SocketFactoryTests: XCTestCase {
    var config: AsyncConfig!
    var logger: Logger!
    var mockAsyncDelegate: MockAsyncDelegate!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let asyncLoggerConfig = LoggerConfig(prefix: "ASYNC_SDK",
                                             logServerURL: "http://10.56.34.61:8080/1m-http-server-test-chat",
                                             logServerMethod: "PUT",
                                             persistLogsOnServer: true,
                                             isDebuggingLogEnabled: true,
                                             logServerRequestheaders: ["Authorization": "Basic Y2hhdDpjaGF0MTIz", "Content-Type": "application/json"])
        logger = Logger(config: asyncLoggerConfig)
        mockAsyncDelegate = MockAsyncDelegate()
        config = try AsyncConfig(socketAddress: "wss://msg.pod.ir/ws",
                                 peerName: "chat-server",
                                 appId: "PodChat",
                                 loggerConfig: asyncLoggerConfig,
                                 reconnectOnClose: true
        )
    }

    func test_createSocket() {
        let async = SocketFactory.create(config: config, delegate: mockAsyncDelegate)
        XCTAssertEqual(async.config.socketAddress, "wss://msg.pod.ir/ws")
    }
}
