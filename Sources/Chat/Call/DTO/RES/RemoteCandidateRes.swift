//
// RemoteCandidateRes.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

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
