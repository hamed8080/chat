//
// MockWebSocketProvider.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
import Logger
@testable import Async

final class MockWebSocketProvider: WebSocketProvider {

    var sendDataResult: ((Data) -> Void)?
    var sendStringResult: ((String) -> Void)?
    var closeConnectionResult: (() -> Void)?
    var connectResult: (() -> Void)?

    init(url: URL, timeout: TimeInterval, logger: Logger) {

    }

    var delegate: WebSocketProviderDelegate?

    func connect() {
        self.connectResult?()
    }

    func closeConnection() {
        closeConnectionResult?()
    }

    func send(data: Data) {
        sendDataResult?(data)
    }

    func send(text: String) {
        sendStringResult?(text)
    }
}
