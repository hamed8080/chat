//
//  StarScreamWebSocketProvider.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/9/21.
//

import Foundation
import Starscream

class StarScreamWebSocketProvider :WebSocketProvider {
	
	var delegate: WebSocketProviderDelegate?
	private let socket: WebSocket
	
	init(url: URL) {
		self.socket = WebSocket(url: url)
		self.socket.delegate = self
	}
	
	func connect() {
		self.socket.connect()
	}
	
	func send(data: Data) {
		self.socket.write(data: data)
	}
	
}

extension StarScreamWebSocketProvider : Starscream.WebSocketDelegate{
	func websocketDidConnect(socket: WebSocketClient) {
		self.delegate?.webSocketDidConnect(self)
	}
	
	func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
		self.delegate?.webSocketDidDisconnect(self)
	}
	
	func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
		debugPrint("Warning: Expected to receive data format but received a string. Check the websocket server config.")
	}
	
	func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
		self.delegate?.webSocketDidReciveData(self, didReceive: data)
	}
}
