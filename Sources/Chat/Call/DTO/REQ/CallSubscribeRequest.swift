//
// CallSubscribeRequest.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Async
import Chat
import ChatCore
import Foundation

struct CallSubscribeRequest: Encodable {
    let brokerAddress: String
    let addition: [Addition]

    init(brokerAddress: String, addition: [Addition]) {
        self.brokerAddress = brokerAddress
        self.addition = addition
    }

    private enum CodingKeys: String, CodingKey {
        case addition = "addition"
        case brokerAddress = "brokerAddress"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(addition, forKey: .addition)
        try container.encode(brokerAddress, forKey: .brokerAddress)
    }
}
