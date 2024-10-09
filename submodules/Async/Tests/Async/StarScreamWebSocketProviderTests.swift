//
// StarScreamWebSocketProviderTests.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import XCTest
import Logger
import Mocks
import Additive
@testable import Async

final class StarScreamWebSocketProviderTests: XCTestCase, WebSocketProviderDelegate {

    var sut: StarScreamWebSocketProvider!
    var url = URL(string: "wss://msg.pod.ir/ws")!
    var timeout: TimeInterval = 10
    var logger: Logger!
    var delegateOnConnectedExp: XCTestExpectation?
    var delegateOnDisconnectedExp: XCTestExpectation?
    var delegateOnDataExp: XCTestExpectation?
    var delegateOnErrorExp: XCTestExpectation?
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
        sut = StarScreamWebSocketProvider(url: url, timeout: timeout, logger: logger)
        sut.delegate = self
    }

    func test_init_isNotConnected() {
        XCTAssertFalse(sut.socket.isConnected, "Expected socket to be in is not connected mode when init called.")
    }

    func test_init_delegateIsNotNil() {
        XCTAssertNotNil(sut.socket.delegate, "Expected the delegate of starscream socket to be set in init method.")
    }

    func test_init_requestTimeoutIsEqualToInitializer() {
        let result = sut.socket.request.timeoutInterval
        XCTAssertEqual(result, 10, "Expected the time out to be equal to 10 but it is \(result)")
    }

    func test_connect_callOnConnectedDelegate() {
        delegateOnConnectedExp = expectation(description: "Expected to call onConnected delegate.")
        queue.async {
            self.sut.connect()
        }
        wait(for: [delegateOnConnectedExp!], timeout: 2)
    }

    func test_didConnect_callOnConnectedDelegate() {
        delegateOnConnectedExp = expectation(description: "Expected to call onConnected delegate.")
        sut.websocketDidConnect(socket: sut.socket)
        wait(for: [delegateOnConnectedExp!], timeout: 1)
    }

    func test_closeConnection_callOnDisconnectedDelegate() {
        delegateOnDisconnectedExp = expectation(description: "Expected to call onConnected delegate.")
        sut.connect()
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
            self.sut.closeConnection()
        }
        wait(for: [delegateOnDisconnectedExp!], timeout: 5)
    }

    func test_didDisconnect_callOnDisConnectedDelegate() {
        delegateOnDisconnectedExp = expectation(description: "Expected to call onDisConnected delegate.")
        sut.websocketDidDisconnect(socket: sut.socket, error: nil)
        wait(for: [delegateOnDisconnectedExp!], timeout: 1)
    }

    func test_didDisconnect_callOnDisConnectedDelegateWithAnError() {
        delegateOnDisconnectedExp = expectation(description: "Expected to call onDisConnected delegate with an error.")
        sut.websocketDidDisconnect(socket: sut.socket, error: AsyncError())
        wait(for: [delegateOnDisconnectedExp!], timeout: 1)
    }

    func test_didReceivedData_callOnReceivedData() {
        delegateOnDataExp = expectation(description: "Expected to call onReceivedData delegate.")
        sut.websocketDidReceiveData(socket: sut.socket, data: "TEST".data(using: .utf8)!)
        wait(for: [delegateOnDataExp!], timeout: 1)
    }

    func test_didReceivedMessage_callOnReceivedData() {
        delegateOnDataExp = expectation(description: "Expected to call onReceivedData delegate.")
        sut.websocketDidReceiveMessage(socket: sut.socket, text: "TEST")
        wait(for: [delegateOnDataExp!], timeout: 1)
    }

    func test_sendData() {
        sut.send(data: "Test".data(using: .utf8)!)
    }

    func test_sendText() {
        sut.send(text: "Test")
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
}
