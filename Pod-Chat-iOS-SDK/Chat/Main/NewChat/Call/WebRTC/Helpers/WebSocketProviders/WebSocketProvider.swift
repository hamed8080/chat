//
//  WebSocketProvider.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/9/21.
//

import Foundation
protocol WebSocketProviderDelegate:AnyObject {
	func webSocketDidConnect(_ webSocket:WebSocketProvider)
	func webSocketDidDisconnect(_ webSocket:WebSocketProvider)
	func webSocketDidReciveData(_ webSocket:WebSocketProvider , didReceive data:Data)
}

protocol WebSocketProvider:AnyObject{
	var delegate:WebSocketProviderDelegate? {get set}
	func connect()
	func send(data:Data)
}
