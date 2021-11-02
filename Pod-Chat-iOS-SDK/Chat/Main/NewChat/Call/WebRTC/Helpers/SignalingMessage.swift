//
//  SignalingMessage.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/10/21.
//

import Foundation
enum SignalingMessageType:String,Codable{
	case sdp = "sdp"
	case offer = "offer"
}
struct SDP:Codable {
	
}

struct Candidate:Codable {
	
}
struct SignalingMessage:Codable {
	let type:SignalingMessageType
	let sdp:SDP?
	let candidate:Candidate?
}
