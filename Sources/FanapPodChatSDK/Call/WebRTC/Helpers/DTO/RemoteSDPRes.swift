//
// RemoteSDPRes.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

//
//  RemoteSDPRes.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 7/31/21.
//
import Foundation
import WebRTC

struct RemoteSDPRes: Codable {
    var id: String = "PROCESS_SDP_ANSWER"
    var topic: String
    var sdpAnswer: String

    var rtcSDP: RTCSessionDescription {
        RTCSessionDescription(type: .answer, sdp: sdpAnswer)
    }
}
