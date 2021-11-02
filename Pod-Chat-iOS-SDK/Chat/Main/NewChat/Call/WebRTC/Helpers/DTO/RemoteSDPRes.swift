//
//  RemoteSDPRes.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/31/21.
//
import Foundation
import WebRTC

struct RemoteSDPRes: Codable {
   
    var id                  :String     = "PROCESS_SDP_ANSWER"
    var topic               :String
    var sdpAnswer           :String
    
    var rtcSDP:RTCSessionDescription{
        RTCSessionDescription(type: .answer, sdp: sdpAnswer)
    }
    
}
