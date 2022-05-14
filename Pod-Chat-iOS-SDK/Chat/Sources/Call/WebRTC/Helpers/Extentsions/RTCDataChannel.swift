//
//  RTCDataChannel.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/9/21.
//

import Foundation
import WebRTC
extension RTCDataChannel{
	
	func sendData(_ data:Data, isBinary:Bool = true){
		if readyState == .open {
			let buffer = RTCDataBuffer(data: data, isBinary: isBinary)
			sendData(buffer)
		}
	}
}
