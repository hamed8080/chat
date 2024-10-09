//
// AsyncTests.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import XCTest
import Logger
import Mocks
import Additive
@testable import Async

final class AsyncTests: XCTestCase {
    var sut: Async!
    var mockAsyncDelegate: MockAsyncDelegate!
    var config: AsyncConfig!
    var logger: Logger!
    var mockSocket: MockWebSocketProvider!
    var queue: DispatchQueueProtocol!

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
        mockSocket = MockWebSocketProvider(url: URL(string: config.socketAddress)!, timeout: config.connectionRetryInterval, logger: logger)
        queue = DispatchQueue.main
        sut = Async(socket: mockSocket,
                    config: config,
                    delegate: mockAsyncDelegate,
                    logger: logger,
                    queue: queue
        )
    }

    public func test_recreate_objectsAreDifferent() {
        // Given
        let before = sut.socket
        // When
        sut.recreate()
        // Then
        let result = sut.socket
        XCTAssertFalse(result === before)
    }

    func test_initCalled_socketIsNotNil() throws {
        // Then
        XCTAssertNotNil(sut.socket, "Socket object should be nil when init called.")
    }

    func test_initDelegate_isNotNil() throws {
        // Then
        XCTAssertNotNil(sut.delegate, "Socket object should be nil when init called.")
    }

    func test_initDelegate_delegateIsNotNil() throws {
        // When
        let sut = Async(socket: mockSocket, config: config, logger: logger)
        // Then
        XCTAssertNil(sut.delegate, "Socket delegate should be nil when init called without a delegate.")
    }

    func test_init_socketDelegateIsNotNil() throws {
        // Then
        XCTAssertNotNil(sut.socket.delegate, "Socket delegate should not be nil when init called.")
    }

    func test_init_loggerDelegateIsNotNil() throws {
        // Then
        XCTAssertNotNil(sut.logger.delegate, "The delegate of the logger object should not b equal to nil but it is \(String(describing: sut.logger.delegate))")
    }

    func test_init_checkConnectionTimerisNil() throws {
        // Given
        sut = Async(socket: mockSocket, config: config, logger: logger)

        // When
        let result = sut.connectionStatusTimer

        // Then
        XCTAssertNil(result, "Check connection timer should be nil but it is \(String(describing: result))")
    }

    func test_connect_statusIsConnecting() throws {
        // Given
        sut.connect()

        // When
        let result = sut.stateModel.socketState

        // Then
        XCTAssertEqual(result, .connecting , "Expexted the connection status to be in connecting state but it is \(result)")
    }

    func test_connect_checkConnectionTimerIsNotNil() throws {
        // Given
        sut.connect()

        // When
        let result = sut.connectionStatusTimer

        // Then
        XCTAssertNotNil(result, "Expexted the connectionStatusTimer to be not nil but it is \(String(describing: result))")
    }

    func test_reconnect_checkConnectionTimerIsNotNil() throws {
        // Given
        sut.reconnect()

        // When
        let result = sut.connectionStatusTimer

        // Then
        XCTAssertNotNil(result, "Expexted the connectionStatusTimer to be not nil when reconnect but it is \(String(describing: result))")
    }

    func test_didDisconnect_stateIsClosed() throws {
        // Given
        mockSocket.delegate?.onDisconnected(mockSocket, nil)

        // When
        let result = sut.stateModel.socketState

        // Then
        XCTAssertEqual(result, .closed, "Expexted the socketState to be not closed when cloesd but it is \(String(describing: result))")
    }

    func test_didConnect_stateIsConnected() throws {
        // Given
        let exp =  expectation(description: "Expected to call on change")
        mockSocket.delegate?.onConnected(mockSocket)

        // When
        queue.async {
            if self.sut.stateModel.socketState == .connected {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp])
    }

    func test_didConnect_retryCountResetToZero() throws {
        // Given
        mockSocket.delegate?.onConnected(mockSocket)

        // When
        let result = sut.stateModel.retryCount

        // Then
        XCTAssertEqual(result, 0, "Expexted the retryCount to be not 0 when connected but it is \(String(describing: result))")
    }

    func test_didConnect_reconnectTimerIsNil() throws {
        // Given
        mockSocket.delegate?.onConnected(mockSocket)

        // When
        let result = sut.reconnectTimer

        // Then
        XCTAssertNil(result, "Expexted the reconnectTimer to be nil when connected but it is \(String(describing: sut.reconnectTimer))")
    }

    func test_clientCalledDispose_timersAreIsNil() throws {
        // Given
        sut.disposeObject()

        // When
        let pingTimerResult = sut.pingTimer
        let reconnectTimerResult = sut.reconnectTimer
        let connectionStatusTimerResult = sut.connectionStatusTimer

        // Then
        XCTAssertNil(pingTimerResult, "Expexted the pingTimer to be nil when dispose called but it is \(String(describing: pingTimerResult))")
        XCTAssertNil(reconnectTimerResult, "Expexted the reconnectTimer to be nil when dispose called but it is \(String(describing: reconnectTimerResult))")
        XCTAssertNil(connectionStatusTimerResult, "Expexted the connectionStatusTimer to be nil when dispose called but it is \(String(describing: connectionStatusTimerResult))")
    }

    func test_socketDidReceiveAnError_timersAreIsNil() throws {
        // Given
        sut.onReceivedError(AsyncError())

        // When
        let result = sut.stateModel.socketState

        // Then
        XCTAssertEqual(result, .closed, "Expexted the socketState to be not cloesd when webSocketReceiveError called but it is \(String(describing: result))")
    }

    func test_socketStateChanged_callAsyncDelegateChanged() throws {
        // Given
        let exp = expectation(description: "Expected to call asyncStateChanged whenever receive an error.")
        sut.onConnected(mockSocket)

        // When
        mockAsyncDelegate.asyncStateChangedResult = { state, error in
            exp.fulfill()
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_socketDidReceiveAnError_callAsyncDelegateChanged() throws {
        // Given
        let exp = expectation(description: "Expected to call asyncStateChanged whenever receive an error.")
        sut.onReceivedError(AsyncError())

        // When
        mockAsyncDelegate.asyncStateChangedResult = { state, error in
            exp.fulfill()
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_clientCalledDispose_delegateIsNil() throws {
        // Given
        sut.disposeObject()

        // When
        let result = sut.delegate

        // Then
        XCTAssertNil(result, "Expexted the delegate to be nil when dispose called but it is \(String(describing: result))")
    }

    func test_receiveData_decodeAsyncMessageAndCallDeleageAsyncMessage() throws {
        // Given
        let data = encodeAsyncMSG(.init(type: .message))!
        let exp = expectation(description: "Expected to call asyncMessage delegate method whenever receive a new message.")

        // When
        mockAsyncDelegate.asyncMessageResult = { message in
            exp.fulfill()
        }
        sut.onReceivedData(mockSocket, didReceive: data)

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_sendPing_emitAnInnterLogMessage() throws {
        // Given
        let data = encodeAsyncMSG(.init(type: .message))!
        let exp = expectation(description: "Expected to call send a ping message and log that ping request.")

        // When
        sut.onReceivedData(mockSocket, didReceive: data)
        mockAsyncDelegate.asyncOnLogResult = { log in
            if log.type == .sent && log.message?.contains("Send an internal message") == true {
                exp.fulfill()
            }
        }
        queue.async {
            self.sut.pingTimer?.fire()
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_connectingForTheFisrtTime_checkConnectionTimerNotBeingCalled() throws {
        // Given
        let exp = expectation(description: "Expected to be in connecting state when user request to connect for the first time.")
        sut.connect()

        // When
        queue.async {
            self.sut.connectionStatusTimer?.fire()
            if self.sut.stateModel.socketState  == .connecting {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_connected_checkConnectionTimerNotBeingCalled() throws {
        // Given
        let exp = expectation(description: "Expected the socket state to be in close state whenever connectionStatusTimer failed to find a new message(Ping or any new message)")
        sut.onDisconnected(mockSocket, nil)
        let data = encodeAsyncMSG(.init(type: .message))!

        // When
        sut.onReceivedData(mockSocket, didReceive: data)

        // When
        queue.async {
            self.sut.connectionStatusTimer?.fire()
            if self.sut.stateModel.socketState  == .closed {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_passedConnectionTimer_timerGetFiredAndStatusHasChangedToClosed() throws {
        // Given
        let exp = expectation(description: "Expected status change to closed due to not receiving any new message or ping response.")
        config = try AsyncConfig(socketAddress: "wss://test", peerName: "", connectionCheckTimeout: 0.05)
        sut = Async(socket: mockSocket, config: config, logger: logger)
        sut.connect()
        let data = encodeAsyncMSG(.init(type: .message))!

        // When
        sut.onReceivedData(mockSocket, didReceive: data)

        // When
        queue.async {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                self.sut.connectionStatusTimer?.fire()
                if self.sut.stateModel.socketState == .closed {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_receiveNonAsyncMessage_loggerDelagteCalled() throws {
        // Given
        let exp = expectation(description: "Expected the logger delegate to be called whenever receive an unknown message")
        let message = "UNMALFORMATED_MESSAGE"
        let data = try JSONEncoder().encode(message)
        mockSocket.delegate?.onReceivedData(mockSocket, didReceive: data)

        // When
        mockAsyncDelegate.asyncOnLogResult = { log in
            if log.type == .internalLog, log.message?.contains("Can not decode the data") == true {
                exp.fulfill()
            }
        }
        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_receivePingMessageForTheFirstTime_deviceIdIsNotNil() throws {
        // Given
        let exp = expectation(description: "Expected the deviceId to be 123 after first time deviceId arrive")
        let data = encodeAsyncMSG(.init(content: "123", type: .ping))!
        mockSocket.delegate?.onReceivedData(mockSocket, didReceive: data)

        // When
        queue.async {
            if self.sut.stateModel.deviceId == "123" {
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1)
    }

    func test_reconnect_refreshRegister() throws {
        // Given
        let exp = expectation(description: "Expected to call register deivice with refresh key equal to true")

        let pingData = encodeAsyncMSG(.init(content: "123", type: .ping))!
        let deviceData = encodeAsyncMSG(.init(content: "123", type: .deviceRegister))!
        mockSocket.delegate?.onReceivedData(mockSocket, didReceive: deviceData)

        //Send Another onPing to reregister device
        // When
        self.mockAsyncDelegate.asyncOnLogResult = { log in
            if let decoded = self.decodeAsyncContent(RegisterDevice.self, log, .deviceRegister), log.type == .sent, decoded.refresh == true {
                exp.fulfill()
            }
        }
        mockSocket.delegate?.onReceivedData(mockSocket, didReceive: pingData)

        wait(for: [exp], timeout: 1)
    }

    func test_receivePingMessageForTheFisrtTime_deviceRegisterRequestSent() throws {
        // Given
        let exp = expectation(description: "Expected to device register sent to server.")
        let data = encodeAsyncMSG(.init(content: "123", type: .ping))!

        // When
        mockAsyncDelegate.asyncOnLogResult = { log in
            if self.decodeLogAsyncMSG(log, .deviceRegister) != nil {
                if log.type == .sent {
                    exp.fulfill()
                }
            }
        }
        mockSocket.delegate?.onReceivedData(mockSocket, didReceive: data)

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_receiveNewUnknownMessage_logAnUnknownType() throws {
        // Given
        let exp = expectation(description: "Expected to receieve an log with message \"UNKOWN type received\"")
        let data = encodeAsyncMSG(.init(content: "123", type: .init(rawValue: -8000)))!

        // When
        mockAsyncDelegate.asyncOnLogResult = { log in
            if log.type == .internalLog, log.message?.contains("UNKOWN type received") == true {
                exp.fulfill()
            }
        }
        mockSocket.delegate?.onReceivedData(mockSocket, didReceive: data)

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_receiveDeviceRegister_isDeviceRegisterTrue() throws {
        // Given
        let exp = expectation(description: "Expected the isDeviceRegistered to be true")
        let expPeerId = expectation(description: "Expected the peerId to be set")
        let data = encodeAsyncMSG(.init(content: "1234", type: .deviceRegister))!

        // When
        mockSocket.delegate?.onReceivedData(mockSocket, didReceive: data)
        queue.async {
            if self.sut.stateModel.isDeviceRegistered == true {
                exp.fulfill()
            }
            if self.sut.stateModel.peerId == 1234 {
                expPeerId.fulfill()
            }
        }

        // Then
        wait(for: [exp, expPeerId], timeout: 1)
    }

    func test_receiveServerRegisterAndSenderNameIsEquelToConfig_isServerRegisteredTrue() throws {
        // Given
        let exp = expectation(description: "Expected the isServerRegistered to be true")
        let data = encodeAsyncMSG(.init(senderName: "chat-server", type: .serverRegister))!

        // When
        mockSocket.delegate?.onReceivedData(mockSocket, didReceive: data)
        queue.async {
            if self.sut.stateModel.isServerRegistered == true, self.sut.stateModel.socketState == .asyncReady {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_receiveServerRegisterAndSenderNameIsNotEquelToConfig_isServerRegisteredTrue() throws {
        // Given
        let exp = expectation(description: "Expected the isServerRegistered to be true")
        let data = encodeAsyncMSG(.init(senderName: "UN_EQUAL_SENDER_NAME", type: .serverRegister))!

        // When
        mockSocket.delegate?.onReceivedData(mockSocket, didReceive: data)
        queue.async {
            if self.sut.stateModel.isServerRegistered == false {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_sendMessageAsyncNotReady_delegateCalledWithAnError() throws {
        // Given
        let exp = expectation(description: "Expected the delegate get called with an error of type socketIsNotConnected")
        let message = SendAsyncMessageVO(content: "", ttl: 0, peerName: "")

        // When
        mockAsyncDelegate.asyncMessageSentResult = { message, error in
            if error?.code == .socketIsNotConnected {
                exp.fulfill()
            }
        }
        sut.send(message: message)

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_sendMessageAsyncIsReady_delegateCalledWithoutAnError() throws {
        // Given
        let exp = expectation(description: "Expected the delegate get called without an error")
        let message = SendAsyncMessageVO(content: "HELLO", ttl: 0, peerName: "")
        let data = encodeAsyncMSG(.init(senderName: "chat-server", type: .serverRegister))!

        // When
        mockSocket.delegate?.onReceivedData(mockSocket, didReceive: data)
        queue.async {
            self.mockAsyncDelegate.asyncMessageSentResult = { message, error in
                if let decoded = self.decodeAsyncMSG(SendAsyncMessageVO.self, message, .message)?.decoded, error == nil, decoded.content == "HELLO" {
                    exp.fulfill()
                }
            }
            self.sut.send(message: message)
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_didDisconnect_reconnectTimerIsNilIfSocketStateBackToConnectOrReady() throws {
        // Given
        let exp = expectation(description: "Expected the delegate get called without an error")
        mockSocket.delegate?.onDisconnected(mockSocket, AsyncError())

        // When
        queue.async {
            self.mockSocket.delegate?.onConnected(self.mockSocket)
            self.sut.reconnectTimer?.fire()
            self.queue.async {
                if self.sut.reconnectTimer == nil {
                    exp.fulfill()
                }
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_didDisconnect_doesNotPassMaxRetryCount() throws {
        // Given
        let exp = expectation(description: "Expected the delegate get called without an error")
        mockSocket.delegate?.onDisconnected(mockSocket, AsyncError())

        // When
        queue.async {
            for _ in 0..<self.config.reconnectCount + 1 {
                self.sut.reconnectTimer?.fire()
            }

            if self.sut.reconnectTimer?.isValid == false {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_messageAckNeeded_sendAcknowledge() throws {
        // Given
        let exp = expectation(description: "Expected the delegate get called without an error")
        let data = encodeAsyncMSG(.init(senderName: "chat-server", id: 123, type: .messageAckNeeded))!

        // When
        sut.onReceivedData(mockSocket, didReceive: data)
        mockAsyncDelegate.asyncOnLogResult = { log in
            let decoded = self.decodeAsyncContent(MessageACK.self, log, .ack)
            if let ack = decoded, log.type == .sent, ack.messageId == 123 {
                exp.fulfill()
            }
        }

        // Then
        wait(for: [exp], timeout: 1)
    }

    func test_closeConnectionCalled_stateIsClosed() throws {
        // Given
        sut.closeConnection()

        // When
        let result = sut.stateModel.socketState

        // Then
        XCTAssertEqual(result, .closed, "Expected the state to be closed but it is \(result))")
    }

    private func decodeAsyncContent<T: Decodable>(_ decodedType: T.Type, _ log: Log, _ type: AsyncMessageTypes) -> T? {
        guard let asyncMSG = decodeLogAsyncMSG(log, type),
              let decoded = try? JSONDecoder().decode(T.self, from: asyncMSG.content!.data(using: .utf8)!) else { return nil }
        return decoded
    }

    private func decodeLogAsyncMSG(_ log: Log, _ type: AsyncMessageTypes) -> AsyncMessage? {
        guard let message = log.userInfo?["\(type.rawValue)"],
              let asyncMessage = decodeAsyncMSG(message.data(using: .utf8)!) else { return nil }
        return asyncMessage
    }

    private func decodeAsyncMSG<T: Decodable>(_ decodeType: T.Type , _ data: Data?, _ type: AsyncMessageTypes) -> (asyncMessge: AsyncMessage, decoded: T)? {
        guard let asyncMessage = decodeAsyncMSG(data),
              let decoded = try? JSONDecoder().decode(T.self, from: asyncMessage.content!.data(using: .utf8)!) else { return nil }
        return (asyncMessage, decoded)
    }

    private func decodeAsyncMSG(_ data: Data?) -> AsyncMessage? {
        return try? JSONDecoder().decode(AsyncMessage.self, from: data!)
    }

    private func encodeAsyncMSG(_ asyncMessage: AsyncMessage) -> Data? {
        return try? JSONEncoder().encode(asyncMessage)
    }
}
