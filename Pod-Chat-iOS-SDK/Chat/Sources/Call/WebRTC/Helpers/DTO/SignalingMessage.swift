//
//  SignalingMessage.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/10/21.
//

import Foundation
import WebRTC
import FanapPodAsyncSDK

enum SdpType:String , Codable {
    case offer
    case prAnswer
    case answer
    case rollback
    
    var rtcSdpType: RTCSdpType {
        switch self {
        case .offer:
            return .offer
        case .answer:
            return .answer
        case .prAnswer:
            return .prAnswer
        case .rollback:
            return .rollback
        }
    }
    
    static func toSdpType(rtcSdpType:RTCSdpType) -> SdpType{
        switch rtcSdpType {
        case .offer:
            return .offer
        case .answer:
            return .answer
        case .prAnswer:
            return .prAnswer
        case .rollback:
            return .rollback
        }
    }
}


struct SessionDescription:Codable {
    
    let sdp  : String
    let type : SdpType
    
    init(from rtcSessionDescription: RTCSessionDescription) {
        self.sdp = rtcSessionDescription.sdp
        
        switch rtcSessionDescription.type {
        case .offer:    self.type = .offer
        case .prAnswer: self.type = .prAnswer
        case .answer:   self.type = .answer
        case .rollback: self.type = .rollback
        @unknown default:
            fatalError("Unknown RTCSessionDescription type: \(rtcSessionDescription.type.rawValue)")
        }
    }
    
    var rtcSessionDescription:RTCSessionDescription {
        return RTCSessionDescription(type: type.rtcSdpType, sdp: sdp)
    }
}

struct IceCandidate:Codable {
    let candidate     : String
    let sdpMLineIndex : Int32
    let sdpMid        : String?
    
    init(from rtcIce:RTCIceCandidate) {
        self.candidate      = rtcIce.sdp
        self.sdpMLineIndex  = rtcIce.sdpMLineIndex
        self.sdpMid         = rtcIce.sdpMid
    }
    
    
    var replaceSpaceSdpIceCandidate:IceCandidate{
        let newICEReplaceSpace = RTCIceCandidate(sdp: candidate, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
        let newIceCandidate = IceCandidate(from: newICEReplaceSpace)
        return newIceCandidate
    }
    
    var rtcIceCandidate: RTCIceCandidate {
        return RTCIceCandidate(sdp: self.candidate, sdpMLineIndex: self.sdpMLineIndex, sdpMid: self.sdpMid)
    }
}

struct SignalingMessage:Codable {
  
    let type         : String?
    let uniqueId     : String?
    let sdp          : SessionDescription?
    let ice          : IceCandidate?
    
    internal init(sdp: SessionDescription) {
        self.sdp            = sdp
        self.ice            = nil
        self.uniqueId       = nil
        self.type           = nil
    }
    
    internal init(ice: IceCandidate?) {
        self.sdp            = nil
        self.ice            = ice
        self.uniqueId       = nil
        self.type           = nil
    }
    
    private enum CodingKeys : String , CodingKey{
        case  type      = "id"
        case  sdp       = "sdp"
        case  ice       = "ice"
        case  uniqueId  = "uniqueId"
    }
    
}
