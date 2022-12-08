//
// RemoteCandidateRes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

//
//  RemoteCandidateRes.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/31/21.
//
import Foundation
import WebRTC

public struct RemoteCandidateRes: Codable {
    let id: String
    let candidate: IceCandidate
    let topic: String
    let webRtcEpId: String

    var rtcIceCandidate: RTCIceCandidate {
        RTCIceCandidate(sdp: candidate.candidate, sdpMLineIndex: candidate.sdpMLineIndex, sdpMid: candidate.sdpMid)
    }
}
