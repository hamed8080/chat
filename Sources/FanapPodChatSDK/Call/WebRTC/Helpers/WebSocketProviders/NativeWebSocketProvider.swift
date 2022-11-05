//
// NativeWebSocketProvider.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

@available(iOS 13.0, *)
class NativeWebSocketProvider: NSObject, WebSocketProvider {
    var delegate: WebSocketProviderDelegate?
    private let url: URL
    private var socket: URLSessionWebSocketTask?
    private lazy var urlSession: URLSession = .init(configuration: .default, delegate: self, delegateQueue: nil)

    init(url: URL) {
        self.url = url
        super.init()
    }

    public func connect() {
        socket = urlSession.webSocketTask(with: url)
        socket?.resume()
        readMessage()
    }

    func send(data: Data) {
        socket?.send(.data(data)) { _ in }
    }

    func send(text: String) {
        socket?.send(.string(text)) { _ in }
    }

    private func readMessage() {
        socket?.receive { message in
            switch message {
            case let .success(message):
                switch message {
                case let .data(data):
                    self.delegate?.webSocketDidReciveData(self, didReceive: data)
                    self.readMessage()
                case let .string(string):
                    self.delegate?.webSocketDidReciveData(self, didReceive: string.data(using: .utf8)!)
                    self.readMessage()
                @unknown default:
                    break
                }
            case let .failure(error):
                Chat.sharedInstance.logger?.log(title: "error on socket", message: "\(error)")
                self.disconnect()
            }
        }
    }

    private func disconnect() {
        socket?.cancel()
        socket = nil
        delegate?.webSocketDidDisconnect(self)
    }
}

@available(iOS 13.0, *)
extension NativeWebSocketProvider: URLSessionDelegate, URLSessionWebSocketDelegate {
    func urlSession(_: URLSession, webSocketTask _: URLSessionWebSocketTask, didOpenWithProtocol _: String?) {
        delegate?.webSocketDidConnect(self)
    }

    func urlSession(_: URLSession, webSocketTask _: URLSessionWebSocketTask, didCloseWith _: URLSessionWebSocketTask.CloseCode, reason _: Data?) {
        delegate?.webSocketDidDisconnect(self)
    }

    func urlSession(_: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
