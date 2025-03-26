//
// ChatDataDTO.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public struct ChatDataDTO: Codable, Sendable {
    public let screenShare: String
    public let turnAddress: String
    public let brokerAddressWeb: String
    public let kurentoAddress: String

    public init(sendMetaData _: String, screenShare: String, reciveMetaData _: String, turnAddress: String, brokerAddressWeb: String, kurentoAddress: String) {
        self.screenShare = screenShare
        self.turnAddress = turnAddress
        self.brokerAddressWeb = brokerAddressWeb
        self.kurentoAddress = kurentoAddress
    }

    private enum CodingKeys: String, CodingKey {
        case screenShare
        case turnAddress
        case brokerAddressWeb
        case kurentoAddress
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        screenShare = try container.decode(String.self, forKey: .screenShare)

        if let firstTurnAddress = try container.decode(String.self, forKey: .turnAddress).split(separator: ",").first {
            turnAddress = String(firstTurnAddress)
        } else {
            turnAddress = ""
        }

        if let brokerAddressWeb = try? container.decode(String.self, forKey: .brokerAddressWeb) {
            self.brokerAddressWeb = brokerAddressWeb
        } else {
            brokerAddressWeb = ""
        }

        if let firstKurentoAddress = try container.decode(String.self, forKey: .kurentoAddress).split(separator: ",").first {
            kurentoAddress = String(firstKurentoAddress)
        } else {
            kurentoAddress = ""
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.screenShare, forKey: .screenShare)
        try container.encode(self.turnAddress, forKey: .turnAddress)
        try container.encode(self.brokerAddressWeb, forKey: .brokerAddressWeb)
        try container.encode(self.kurentoAddress, forKey: .kurentoAddress)
    }
}
