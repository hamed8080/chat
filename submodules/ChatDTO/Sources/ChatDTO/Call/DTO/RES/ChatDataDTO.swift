//
// ChatDataDTO.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public struct ChatDataDTO: Codable, Sendable {
    public let metaData: String
    public let kurentoAddress: [String]
    public let turnAddress: [String]
    public let internalTurnAddress: [String]
    public let brokerAddress: [String]
    public let brokerAddressWeb: [String]
    public let screenShare: String
    public let screenShareUser: String
    public let recordingUser: String

    public init(
        metaData: String, kurentoAddress: [String], turnAddress: [String],
        internalTurnAddress: [String], brokerAddress: [String],
        brokerAddressWeb: [String], screenShare: String, screenShareUser: String,
        recordingUser: String
    ) {
        self.metaData = metaData
        self.kurentoAddress = kurentoAddress
        self.turnAddress = turnAddress
        self.internalTurnAddress = internalTurnAddress
        self.brokerAddress = brokerAddress
        self.brokerAddressWeb = brokerAddressWeb
        self.screenShare = screenShare
        self.screenShareUser = screenShareUser
        self.recordingUser = recordingUser
    }

    private enum CodingKeys: String, CodingKey {
        case metaData = "metaData"
        case kurentoAddress = "kurentoAddress"
        case turnAddress = "turnAddress"
        case internalTurnAddress = "internalTurnAddress"
        case brokerAddress = "brokerAddress"
        case brokerAddressWeb = "brokerAddressWeb"
        case screenShare = "screenShare"
        case screenShareUser = "screenShareUser"
        case recordingUser = "recordingUser"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        metaData = try container.decode(String.self, forKey: .metaData)
        
        let kurentoAddressString = try container.decode(String.self, forKey: .kurentoAddress)
        kurentoAddress = Array(kurentoAddressString.split(separator: ",").compactMap{ String($0) })
        
        let turnAddressString = try container.decode(String.self, forKey: .turnAddress)
        turnAddress = Array(turnAddressString.split(separator: ",").compactMap{ String($0) })
        
        let internalTurnAddressString = try container.decode(String.self, forKey: .internalTurnAddress)
        internalTurnAddress = Array(internalTurnAddressString.split(separator: ",").compactMap{ String($0) })
        
        let brokerAddressString = try container.decode(String.self, forKey: .brokerAddress)
        brokerAddress = Array(brokerAddressString.split(separator: ",").compactMap{ String($0) })
        
        let brokerAddressWebString = try container.decode(String.self, forKey: .brokerAddressWeb)
        brokerAddressWeb = Array(brokerAddressWebString.split(separator: ",").compactMap{ String($0) })
        
        screenShare = try container.decode(String.self, forKey: .screenShare)
        screenShareUser = try container.decode(String.self, forKey: .screenShareUser)
        recordingUser = try container.decode(String.self, forKey: .recordingUser)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.screenShare, forKey: .screenShare)
        try container.encode(self.turnAddress, forKey: .turnAddress)
        try container.encode(self.brokerAddressWeb, forKey: .brokerAddressWeb)
        try container.encode(self.kurentoAddress, forKey: .kurentoAddress)
    }
}
