// SendRequestReceivingMedia.swift
// Copyright (c) 2022 ChatCall
//
// Created by Hamed Hosseini on 12/16/22

import Async
import Chat
import ChatCore
import Foundation

struct SendRequestReceivingMedia: Encodable {
    let brokerAddress: String

    init(brokerAddress: String) {
        self.brokerAddress = brokerAddress
    }

    private enum CodingKeys: String, CodingKey {
        case brokerAddress = "brokerAddress"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(brokerAddress, forKey: .brokerAddress)
    }
}
