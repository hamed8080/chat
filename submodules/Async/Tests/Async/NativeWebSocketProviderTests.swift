//
// NativeWebSocketProviderTests.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import XCTest
import Logger
import Mocks
import Additive
import Logger
@testable import Async

@available(iOS 13.0, *)
final class NativeWebSocketProviderTests: XCTestCase, WebSocketProviderDelegate, LogDelegate {
    var sut: NativeWebSocketProvider!
    var url = URL(string: "wss://msg.pod.ir/ws")!
    var timeout: TimeInterval = 10
    var logger: Logger!
    var delegateOnConnectedExp: XCTestExpectation?
    var delegateOnDisconnectedExp: XCTestExpectation?
    var delegateOnDataExp: XCTestExpectation?
    var delegateOnErrorExp: XCTestExpectation?
    var delegateOnLogExp: XCTestExpectation?
    var queue = DispatchQueue.main

    override func setUpWithError() throws {
        try super.setUpWithError()
        let asyncLoggerConfig = LoggerConfig(prefix: "ASYNC_SDK",
                                             logServerURL: "http://10.56.34.61:8080/1m-http-server-test-chat",
                                             logServerMethod: "PUT",
                                             persistLogsOnServer: true,
                                             isDebuggingLogEnabled: true,
                                             logServerRequestheaders: ["Authorization": "Basic Y2hhdDpjaGF0MTIz", "Content-Type": "application/json"])
        logger = Logger(config: asyncLoggerConfig)
        logger.delegate = self
        sut = NativeWebSocketProvider(url: url, timeout: timeout, logger: logger)
        sut.delegate = self
    }

    func test_connect_delegateGetCalled() {
        // Given
        delegateOnConnectedExp = expectation(description: "Expected to connect to server and delegate get called.")
        sut.connect()

        // When
        wait(for: [delegateOnConnectedExp!], timeout: 2)
    }

    func test_closeConnection_delegateGetCalled() {
        // Given
        delegateOnDisconnectedExp = expectation(description: "Expected to connect to server and delegate get called.")
        sut.connect()

        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            self.sut.closeConnection()
        }
        wait(for: [delegateOnDisconnectedExp!], timeout: 3)
    }

    func test_sendDataIfIsConnected_delegateGetCalled() {
        // Given
        delegateOnErrorExp = expectation(description: "Expected error delegate get called.")

        // When
        sut.send(data: "TEST".data(using: .utf8)!)

        // Then
        wait(for: [delegateOnErrorExp!], timeout: 1)
    }

    func test_sendTextIfIsConnected_delegateGetCalled() {
        // Given
        delegateOnErrorExp = expectation(description: "Expected error delegate get called.")

        // When
        sut.send(text: "TEST")

        // Then
        wait(for: [delegateOnErrorExp!], timeout: 1)
    }

    func test_callSendDataWhenIsConnected_logDelegateGetCalled() {
        // Given
        delegateOnLogExp = expectation(description: "Expected error delegate get called.")
        sut.connect()
        sut.isConnected = true

        // When
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            self.sut.send(data: "TEST".data(using: .utf8)!)
        }

        // Then
        wait(for: [delegateOnLogExp!], timeout: 3)
    }

    func test_callSendTextWhenIsConnected_logDelegateGetCalled() {
        // Given
        delegateOnLogExp = expectation(description: "Expected error delegate get called.")
        sut.connect()
        sut.isConnected = true

        // When
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            self.sut.send(text: "TEST")
        }

        // Then
        wait(for: [delegateOnLogExp!], timeout: 3)
    }

    func test_handleError_onDidconnectedGetCalled() {
        // Given
        delegateOnDisconnectedExp = expectation(description: "Expected error delegate get called when we get error of type 54.")

        // When
        sut.handleError(NSError(domain: "", code: 54))

        // Then
        wait(for: [delegateOnDisconnectedExp!], timeout: 1)
    }

    func onConnected(_ webSocket: WebSocketProvider) {
        queue.async {
            self.delegateOnConnectedExp?.fulfill()
        }
    }

    func onDisconnected(_ webSocket: WebSocketProvider, _ error: Error?) {
        queue.async {
            self.delegateOnDisconnectedExp?.fulfill()
        }
    }

    func onReceivedData(_ webSocket: WebSocketProvider, didReceive data: Data) {
        queue.async {
            self.delegateOnDataExp?.fulfill()
        }
    }

    func onReceivedError(_ error: Error?) {
        queue.async {
            self.delegateOnErrorExp?.fulfill()
        }
    }

    func onLog(log: Log) {
        queue.async {
            self.delegateOnLogExp?.fulfill()
        }
    }
}
