//
// CreateSessionReq.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Chat
import Foundation
import Async
import ChatCore

class CreateSessionReq: Encodable {
    var brokerAddress: String
    var turnAddress: String

    public init(turnAddress: String, brokerAddress: String) {
        self.turnAddress = turnAddress
        self.brokerAddress = brokerAddress
    }

    private enum CodingKeys: String, CodingKey {
        case turnAddress = "turnAddress"
        case brokerAddress = "brokerAddress"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(turnAddress, forKey: .turnAddress)
        try container.encode(brokerAddress, forKey: .brokerAddress)
    }
}
