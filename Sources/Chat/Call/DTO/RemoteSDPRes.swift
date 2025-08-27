//
// RemoteSDPRes.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import WebRTC

public struct RemoteSDPRes: Codable {
    let id: CallMessageType = .processSdpAnswer
    let topic: String
    let sdpAnswer: String

    var rtcSDP: RTCSessionDescription {
        RTCSessionDescription(type: .answer, sdp: sdpAnswer)
    }
}
