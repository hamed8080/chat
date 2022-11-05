//
// ChatDataDTO.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public struct ChatDataDTO: Codable {
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
}
