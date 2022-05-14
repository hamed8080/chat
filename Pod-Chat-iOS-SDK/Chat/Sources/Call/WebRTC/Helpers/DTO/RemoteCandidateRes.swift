//
//  RemoteCandidateRes.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/31/21.
//
import Foundation
import WebRTC

struct RemoteCandidateRes: Codable {
   
    let id            : String
    let candidate     : IceCandidate
    let topic         : String
    let webRtcEpId    : String
    
    var rtcIceCandidate: RTCIceCandidate {
        return RTCIceCandidate(sdp: self.candidate.candidate, sdpMLineIndex: self.candidate.sdpMLineIndex, sdpMid: self.candidate.sdpMid)
    }
    
    
}
