//
// SendNegotiationReq.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

struct SendNegotiationReq: Codable {
    var brokerAddress: String
    var sdpOffer: String
    let addition: [Addition]
    
    public init( sdpOffer: String, brokerAddress: String, additions: [Addition]) {
        self.brokerAddress = brokerAddress
        self.sdpOffer = sdpOffer
        self.addition = additions
    }
    
    private enum CodingKeys: String, CodingKey {
        case brokerAddress = "brokerAddress"
        case sdpOffer = "sdpOffer"
        case addition = "addition"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.brokerAddress, forKey: .brokerAddress)
        try container.encode(self.sdpOffer, forKey: .sdpOffer)
        try container.encode(self.addition, forKey: .addition)
    }
}
