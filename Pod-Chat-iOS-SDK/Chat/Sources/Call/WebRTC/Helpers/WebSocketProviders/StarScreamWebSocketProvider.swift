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
        self.socket.disableSSLCertValidation = true
		self.socket.delegate = self
	}
	
	func connect() {
		self.socket.connect()
	}
	
	func send(data: Data) {
		self.socket.write(data: data)
	}
    
    func send(text: String) {
        self.socket.write(string: text)
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
        guard let data = text.data(using: .utf8)else{return}
        self.delegate?.webSocketDidReciveData(self, didReceive: data)
	}
	
	func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
		self.delegate?.webSocketDidReciveData(self, didReceive: data)
	}
}
