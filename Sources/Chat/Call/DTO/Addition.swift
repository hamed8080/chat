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
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.mline, forKey: .mline)
        try container.encodeIfPresent(self.clientId, forKey: .clientId)
        try container.encode(self.topic, forKey: .topic)
        try container.encode(self.mediaType, forKey: .mediaType)
        try container.encodeIfPresent(self.mids, forKey: .mids)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mline = try container.decode(Int.self, forKey: .mline)
        self.clientId = try container.decodeIfPresent(Int.self, forKey: .clientId)
        self.topic = try container.decode(String.self, forKey: .topic)
        self.mediaType = try container.decode(MediaType.self, forKey: .mediaType)
        self.mids = try container.decodeIfPresent([String].self, forKey: .mids)
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
