//
// SendClient.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public struct SendClient: Codable, Sendable {
    public let id: String?
    public let type: ClientType
    public let deviceId: String?
    public let mute: Bool
    public let video: Bool
    public let desc: String?

    public init(id: String? = nil, type: ClientType = .ios, deviceId: String? = nil, mute: Bool = true, video: Bool = false, desc: String? = nil) {
        self.id = id
        self.type = type
        self.deviceId = deviceId
        self.mute = mute
        self.video = video
        self.desc = desc
    }

    private enum CodingKeys: String, CodingKey {
        case id = "clientId"
        case type = "clientType"
        case deviceId
        case mute
        case video
        case desc
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(deviceId, forKey: .deviceId)
        try container.encode(mute, forKey: .mute)
        try container.encode(video, forKey: .video)
        try container.encodeIfPresent(desc, forKey: .desc)
    }
}
