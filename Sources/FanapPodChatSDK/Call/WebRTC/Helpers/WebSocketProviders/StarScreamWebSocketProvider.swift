//
// StarScreamWebSocketProvider.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
import Starscream

class StarScreamWebSocketProvider: WebSocketProvider {
    var delegate: WebSocketProviderDelegate?
    private let socket: WebSocket

    init(url: URL) {
        socket = WebSocket(url: url)
        socket.disableSSLCertValidation = true
        socket.delegate = self
    }

    func connect() {
        socket.connect()
    }

    func send(data: Data) {
        socket.write(data: data)
    }

    func send(text: String) {
        socket.write(string: text)
    }
}

extension StarScreamWebSocketProvider: Starscream.WebSocketDelegate {
    func websocketDidConnect(socket _: WebSocketClient) {
        delegate?.webSocketDidConnect(self)
    }

    func websocketDidDisconnect(socket _: WebSocketClient, error _: Error?) {
        delegate?.webSocketDidDisconnect(self)
    }

    func websocketDidReceiveMessage(socket _: WebSocketClient, text: String) {
        guard let data = text.data(using: .utf8) else { return }
        delegate?.webSocketDidReciveData(self, didReceive: data)
    }

    func websocketDidReceiveData(socket _: WebSocketClient, data: Data) {
        delegate?.webSocketDidReciveData(self, didReceive: data)
    }
}
