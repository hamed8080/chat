//
// IceCandidate.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Chat
import Foundation
import WebRTC

public struct IceCandidate: Codable {
    let candidate: String
    let sdpMLineIndex: Int32
    let sdpMid: String?
    let usernameFragment: String?

    init(from rtcIce: RTCIceCandidate) {
        candidate = rtcIce.sdp
        sdpMLineIndex = rtcIce.sdpMLineIndex
        sdpMid = rtcIce.sdpMid
        usernameFragment = nil
    }

//    var replaceSpaceSdpIceCandidate: IceCandidate {
//        let newICEReplaceSpace = RTCIceCandidate(sdp: candidate, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
//        let newIceCandidate = IceCandidate(from: newICEReplaceSpace)
//        return newIceCandidate
//    }
//
    var rtcIceCandidate: RTCIceCandidate {
        RTCIceCandidate(sdp: candidate, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
    }

    enum CodingKeys: String, CodingKey {
        case candidate = "candidate"
        case sdpMLineIndex = "sdpMLineIndex"
        case sdpMid = "sdpMid"
        case usernameFragment = "usernameFragment"
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.candidate, forKey: .candidate)
        try container.encode(self.sdpMLineIndex, forKey: .sdpMLineIndex)
        try container.encodeIfPresent(self.sdpMid, forKey: .sdpMid)
        try container.encodeIfPresent(self.usernameFragment, forKey: .usernameFragment)
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.candidate = try container.decode(String.self, forKey: .candidate)
        self.sdpMLineIndex = try container.decode(Int32.self, forKey: .sdpMLineIndex)
        self.sdpMid = try container.decodeIfPresent(String.self, forKey: .sdpMid)
        self.usernameFragment = try container.decodeIfPresent(String.self, forKey: .usernameFragment)
    }
}
