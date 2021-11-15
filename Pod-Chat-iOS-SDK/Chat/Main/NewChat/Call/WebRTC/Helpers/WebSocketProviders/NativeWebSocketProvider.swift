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
        self.socket = urlSession.webSocketTask(with: url)
        self.socket?.resume()
        self.readMessage()
	}
	
	func send(data: Data) {
		self.socket?.send(.data(data)) { _ in }
	}
    
    func send(text: String) {
        self.socket?.send(.string(text)) {_ in}
    }
	
	private func readMessage() {
		self.socket?.receive { message in
			switch message {
                case .success(let message):
                    switch message {
                    case .data(let data):
                        self.delegate?.webSocketDidReciveData(self, didReceive: data)
                        self.readMessage()
                        break
                    case .string(let string):
                        self.delegate?.webSocketDidReciveData(self, didReceive: string.data(using: .utf8)!)
                        self.readMessage()
                        break
                    }
                    break
				case .failure(let error):
                    Chat.sharedInstance.logger?.log(title: "error on socket", message: "\(error)")
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
        
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
