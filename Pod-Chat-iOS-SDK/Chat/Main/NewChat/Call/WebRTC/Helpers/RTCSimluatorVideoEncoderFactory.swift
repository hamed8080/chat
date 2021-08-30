//
//  RTCSimluatorVideoEncoderFactory.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/9/21.
//

import Foundation
import Foundation
import WebRTC

class RTCSimluatorVideoEncoderFactory: RTCDefaultVideoEncoderFactory {
	
	override init() {
		super.init()
	}
	
	override class func supportedCodecs() -> [RTCVideoCodecInfo] {
		var codecs = super.supportedCodecs()
		codecs = codecs.filter{$0.name != "H264"}
		return codecs
	}
}

extension RTCDefaultVideoEncoderFactory{
	
	class var `default` : RTCDefaultVideoEncoderFactory{
		if TARGET_OS_SIMULATOR != 0{
			return RTCSimluatorVideoEncoderFactory()
		}
        
		let encoder =  RTCDefaultVideoEncoderFactory()
        encoder.preferredCodec = RTCVideoCodecInfo(name: kRTCVideoCodecVp8Name)
        return encoder
	}
	
}
