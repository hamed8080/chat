//
// SendOfferSDPReq.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Chat
import Foundation
import Async
import ChatCore

struct SendOfferSDPReq: Codable {
    var brokerAddress: String
    var sdpOffer: String
    let addition: [Addition]
    
    public init(brokerAddress: String, topic: String, sdpOffer: String, mediaType: MediaType) {
        self.brokerAddress = brokerAddress
        self.sdpOffer = sdpOffer
        self.addition = [Addition(mline: 0, clientId: nil, topic: topic, mediaType: mediaType)]
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

