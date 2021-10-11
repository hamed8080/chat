//
//  WebRTCConfig.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/8/21.
//

import Foundation

public struct VideoConfig {
	
    
    public let width                     : Int
    public let height                    : Int
    public let fps                       : Int
    public let localVideoViewFrame       : CGRect?
    public let remoteVideoViewFrame      : CGRect?
	
    public init( width: Int = 640 , height: Int = 640*16/9, fps: Int = 30 , localVideoViewFrame:CGRect , remoteVideoViewFrame:CGRect) {
        
        self.width                        = width
        self.height                       = height
        self.fps                          = fps
        self.localVideoViewFrame          = localVideoViewFrame
        self.remoteVideoViewFrame         = remoteVideoViewFrame
	}
	
}

public struct WebRTCConfig {


    public let peerName                  : String
    public let iceServers                : [String]
    public let turnAddress               : String
    public let brokerAddressWeb          : String
    public let topicVideoSend            : String?
    public let topicVideoReceive         : String?
    public let topicAudioSend            : String?
    public let topicAudioReceive         : String?
    public let dataChannel               : Bool
    public let customFrameCapturer       : Bool
    public let userName                  : String?
    public let password                  : String?
    
    
    public let videoConfig               : VideoConfig?
	
	
	
    public init(peerName                        : String,
                iceServers                      : [String],
                turnAddress                     : String,
                topicVideoSend                  : String?,
                topicVideoReceive               : String?,
                topicAudioSend                  : String?,
                topicAudioReceive               : String?,
                brokerAddressWeb                : String,
                dataChannel                     : Bool          = false,
                customFrameCapturer             : Bool          = false,
                userName                        : String?       = nil,
                password                        : String?       = nil,
                videoConfig                     : VideoConfig?  = nil
	) {
        self.peerName                     = peerName
        self.iceServers                   = iceServers
        self.turnAddress                  = turnAddress
        self.topicVideoSend               = topicVideoSend
        self.topicVideoReceive            = topicVideoReceive
        self.topicAudioSend               = topicAudioSend
        self.topicAudioReceive            = topicAudioReceive
        self.brokerAddressWeb             = brokerAddressWeb
        self.dataChannel                  = dataChannel
        self.customFrameCapturer          = customFrameCapturer
        self.userName                     = userName
        self.password                     = password
        self.videoConfig                  = videoConfig
	}
    
    var firstBorokerAddressWeb:String{
        if let firstBrokerAddressWeb = brokerAddressWeb.split(separator: ",").first{
            return String(firstBrokerAddressWeb)
        }else{
            return ""
        }
    }
}
