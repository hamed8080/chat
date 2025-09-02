//
// ReceiveSDPAnswerReq.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Async
import Chat
import ChatCore
import Foundation

struct ReceiveSDPAnswerReq: Encodable {
    var brokerAddress: String
    var sdpAnswer: String
    let addition: [Addition]

    public init(sdpAnswer: String, addition: [Addition], brokerAddress: String) {
        self.brokerAddress = brokerAddress
        self.sdpAnswer = sdpAnswer
        self.addition = addition
    }

    private enum CodingKeys: String, CodingKey {
        case brokerAddress = "brokerAddress"
        case sdpAnswer = "sdpAnswer"
        case addition = "addition"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.brokerAddress, forKey: .brokerAddress)
        try container.encode(self.sdpAnswer, forKey: .sdpAnswer)
        try container.encode(self.addition, forKey: .addition)
    }
}
