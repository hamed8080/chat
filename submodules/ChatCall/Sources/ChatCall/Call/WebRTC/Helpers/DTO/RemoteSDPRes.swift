//
// RemoteSDPRes.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import WebRTC

public struct RemoteSDPRes: Codable {
    var id: String = "PROCESS_SDP_ANSWER"
    var topic: String
    var sdpAnswer: String

    var rtcSDP: RTCSessionDescription {
        RTCSessionDescription(type: .answer, sdp: sdpAnswer)
    }
}
