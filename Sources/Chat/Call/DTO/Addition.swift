//
// Addition.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import WebRTC

struct Addition: Codable {
    let mline: Int
    let clientId: Int?
    let topic: String
    let mediaType: MediaType
    let mids: [String]?
    
    init(mline: Int, clientId: Int?, topic: String, mediaType: MediaType, mids: [String]? = nil) {
        self.mline = mline
        self.clientId = clientId
        self.topic = topic
        self.mediaType = mediaType
        self.mids = mids
    }
    
    enum CodingKeys: String, CodingKey {
        case mline = "mline"
        case clientId = "clientId"
        case topic = "topic"
        case mediaType = "mediaType"
        case mids = "mids"
    }
}
extension Addition {
    var videoKey: String { kRTCMediaConstraintsOfferToReceiveVideo }
    var audioKey: String { kRTCMediaConstraintsOfferToReceiveAudio }
    var rtcTrue: String { kRTCMediaConstraintsValueTrue }
    var rtcFalse: String { kRTCMediaConstraintsValueFalse }
    
    var constraintsArray: [String: String] {
        [
            videoKey: mediaType == .video ? rtcTrue : rtcFalse,
            audioKey: mediaType == .audio ? rtcTrue : rtcFalse
        ]
    }
    
    var constraints: RTCMediaConstraints {
        RTCMediaConstraints(mandatoryConstraints: constraintsArray, optionalConstraints: nil)
    }
}
