//
// WebSocketProvider.swift
// Copyright (c) 2022 Async
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
import Logger

/// A delegate to raise events.
public protocol WebSocketProviderDelegate: AnyObject {
    /// A delegate method that informs the connection provider connected successfully.
    func onConnected(_ webSocket: WebSocketProvider)

    /// A delegate method that informs the connection provider disconnected successfully.
    func onDisconnected(_ webSocket: WebSocketProvider, _ error: Error?)

    /// A delegate method that informs the connection has received a message.
    func onReceivedData(_ webSocket: WebSocketProvider, didReceive data: Data)

    /// A delegate method that informs an error has happened.
    func onReceivedError(_ error: Error?)
}

public protocol WebSocketProvider: AnyObject {
    /// default initializer for an Async provider.
    init(url: URL, timeout: TimeInterval, logger: Logger)

    /// A delegation provider to inform events.
    var delegate: WebSocketProviderDelegate? { get set }

    /// A method to try to connect the WebSocket server.
    func connect()

    /// Force to close connection by client.
    func closeConnection()

    /// Send a message to the async server with the type of stream data.
    func send(data: Data)

    /// Send a message to the async server with the type of text.
    func send(text: String)
}
