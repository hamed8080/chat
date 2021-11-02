//
//  RTCSimluatorVideoEncoderFactory.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/9/21.
//

import Foundation
import Foundation
import WebRTC


class RTCSimulatorVideoDecoderFactory: RTCDefaultVideoDecoderFactory {
	
	override init() {
		super.init()
	}
	
	override func supportedCodecs() -> [RTCVideoCodecInfo] {
		var codecs = super.supportedCodecs()
		codecs = codecs.filter{$0.name != "H264"}
		return codecs
	}
}

extension RTCDefaultVideoDecoderFactory{
	
	class var `default` : RTCDefaultVideoDecoderFactory{
		if TARGET_OS_SIMULATOR != 0{
			return RTCSimulatorVideoDecoderFactory()
		}
		return RTCDefaultVideoDecoderFactory()
	}
	
}
