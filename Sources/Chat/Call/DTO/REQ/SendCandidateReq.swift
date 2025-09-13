//
// SendCandidateReq.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Chat
import Foundation
import Async
import ChatCore

struct SendCandidateReq: Encodable {
    let brokerAddress: String
    let iceCandidate: IceCandidate

    public init(iceCandidate: IceCandidate, brokerAddress: String) {
        self.iceCandidate = iceCandidate
        self.brokerAddress = brokerAddress
    }

    private enum CodingKeys: String, CodingKey {
        case iceCandidate = "iceCandidate"
        case brokerAddress = "brokerAddress"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let iceData = try? JSONEncoder.instance.encode(iceCandidate)
        if let data = iceData, let stringIce = String(data: data, encoding: .utf8) {
            try container.encode(stringIce, forKey: .iceCandidate)
        }
        try container.encode(self.brokerAddress, forKey: .brokerAddress)
    }
}
