//
// SocketFactory.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
import Logger

public enum SocketFactory {
    public static func createSocket(url: URL, timeout: TimeInterval, logger: Logger) -> WebSocketProvider {
        return NativeWebSocketProvider(url: url, timeout: timeout, logger: logger)
    }

    public static func create(config: AsyncConfig, delegate: AsyncDelegate) -> Async {
        let logger = Logger(config: config.loggerConfig)
        let url = URL(string: config.socketAddress)!
        let socket = createSocket(url: url, timeout: config.connectionRetryInterval, logger: logger)
        return Async(socket: socket, config: config, delegate: delegate, logger: logger)
    }
}
