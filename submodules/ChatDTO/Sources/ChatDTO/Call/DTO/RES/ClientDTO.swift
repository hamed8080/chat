//
// ClientDTO.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public struct ClientDTO: Codable, Sendable {
    public let clientId: Int
    public let topicReceive: String?
    public let topicSend: String
    public let desc: String?
    public let sendKey: String?
    public let video: Bool
    public let mute: Bool
    public let userId: Int

    public init(clientId: Int, topicReceive: String?, topicSend: String, userId: Int, desc: String?, sendKey: String?, video: Bool, mute: Bool) {
        self.clientId = clientId
        self.topicReceive = topicReceive
        self.topicSend = topicSend
        self.userId = userId
        self.desc = desc
        self.sendKey = sendKey
        self.video = video
        self.mute = mute
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.clientId, forKey: .clientId)
        try container.encodeIfPresent(self.topicReceive, forKey: .topicReceive)
        try container.encode(self.topicSend, forKey: .topicSend)
        try container.encodeIfPresent(self.desc, forKey: .desc)
        try container.encodeIfPresent(self.sendKey, forKey: .sendKey)
        try container.encode(self.video, forKey: .video)
        try container.encode(self.mute, forKey: .mute)
        try container.encode(self.userId, forKey: .userId)
    }

    private enum CodingKeys: CodingKey {
        case clientId
        case topicReceive
        case topicSend
        case desc
        case sendKey
        case video
        case mute
        case userId
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
        
        self.topicReceive = try container.decodeIfPresent(String.self, forKey: .topicReceive)
        self.topicSend = try container.decode(String.self, forKey: .topicSend)
        self.desc = try container.decodeIfPresent(String.self, forKey: .desc)
        self.sendKey = try container.decodeIfPresent(String.self, forKey: .sendKey)
        self.video = try container.decode(Bool.self, forKey: .video)
        self.mute = try container.decode(Bool.self, forKey: .mute)
        self.userId = try container.decode(Int.self, forKey: .userId)
    }
}
