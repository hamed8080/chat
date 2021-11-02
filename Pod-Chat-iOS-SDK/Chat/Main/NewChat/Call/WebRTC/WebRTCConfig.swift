//
//  WebRTCConfig.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/8/21.
//

import Foundation

public struct VideoConfig {
	
	public let width:Int
	public let height:Int
	public let fps:Int
	public let localVideoViewFrame		: CGRect?
	public let remoteVideoViewFrame		: CGRect?
	
	public init(width: Int = 640 , height: Int = 640*16/9, fps: Int = 30 , localVideoViewFrame:CGRect , remoteVideoViewFrame:CGRect) {
		self.width = width
		self.height = height
		self.fps = fps
		self.localVideoViewFrame = localVideoViewFrame
		self.remoteVideoViewFrame = remoteVideoViewFrame
	}
	
}

public struct WebRTCConfig {

	public let videoTrack          : Bool
	public let audioTrack          : Bool
	public let dataChannel         : Bool
	public let customFrameCapturer  : Bool
	public let turnServerAddress	: String
	public let videoConfig		: VideoConfig?
	
	
	
	public init(videoTrack: Bool = false,
				audioTrack: Bool = false,
				dataChannel: Bool = false,
				customFrameCapturer: Bool = false,
				turnServerAddress :String? = nil,
				videoConfig:VideoConfig? = nil
	) {
		self.videoTrack          = videoTrack
		self.audioTrack          = audioTrack
		self.dataChannel         = dataChannel
		self.customFrameCapturer  = customFrameCapturer
		self.turnServerAddress = turnServerAddress ?? ""
		self.videoConfig = videoConfig
	}
}
