//
// CallReconnect.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public struct CallReconnect: Decodable, Sendable {
    public let clientId: Int
    public let desc: String?
    public let video: Bool
    public let mute: Bool
    public let raiseHand: Bool
    
    public init(clientId: Int, desc: String? = nil, video: Bool, mute: Bool, raiseHand: Bool) {
        self.clientId = clientId
        self.desc = desc
        self.video = video
        self.mute = mute
        self.raiseHand = raiseHand
    }

    private enum CodingKeys: CodingKey {
        case clientId
        case desc
        case video
        case mute
        case raiseHand
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let clientIdString = try container.decode(String.self, forKey: .clientId)
        guard let clientId = Int(clientIdString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .clientId,
                in: container,
                debugDescription: "clientId must be an Int in String format"
            )
        }
        self.clientId = clientId
        self.desc = try container.decodeIfPresent(String.self, forKey: .desc)
        self.video = try container.decode(Bool.self, forKey: .video)
        self.mute = try container.decode(Bool.self, forKey: .mute)
        self.raiseHand = try container.decode(Bool.self, forKey: .raiseHand)
    }
}
