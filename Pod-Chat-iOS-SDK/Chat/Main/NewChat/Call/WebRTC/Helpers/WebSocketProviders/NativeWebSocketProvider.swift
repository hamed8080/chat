//
//  NativeWebSocketProvider.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/9/21.
//

import Foundation

@available(iOS 13.0, *)
class NativeWebSocketProvider : NSObject , WebSocketProvider{
	
	var delegate: WebSocketProviderDelegate?
	private let url:URL
	private var socket: URLSessionWebSocketTask?
	private lazy var urlSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
	
	init(url:URL) {
		self.url = url
		super.init()
	}
	
	public func connect() {
		let socket = urlSession.webSocketTask(with: url)
		socket.resume()
		self.socket = socket
		self.readMessage()
	}
	
	func send(data: Data) {
		self.socket?.send(.data(data)) { _ in }
	}
	
	private func readMessage() {
		self.socket?.receive { [weak self] message in
			guard let self = self else { return }
			
			switch message {
                case .success(.string(let string)):
                    self.delegate?.webSocketDidReciveData(self, didReceive: string.data(using: .utf8)!)
                    break
				case .success(.data(let data)):
					self.delegate?.webSocketDidReciveData(self, didReceive: data)
					break
				case .success:
					debugPrint("Warning: Expected to receive data format but received a string. Check the websocket server config.")
                    break
				case .failure:
					self.disconnect()
			}
		}
	}
	
	private func disconnect() {
		self.socket?.cancel()
		self.socket = nil
		self.delegate?.webSocketDidDisconnect(self)
	}
}

@available(iOS 13.0, *)
extension NativeWebSocketProvider: URLSessionDelegate , URLSessionWebSocketDelegate{
	
	func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
		delegate?.webSocketDidConnect(self)
	}
	
	func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
		delegate?.webSocketDidDisconnect(self)
	}
}
