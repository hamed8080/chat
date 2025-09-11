//
// EndScreenShareResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation

public struct EndScreenShareResponse: Codable, Sendable {
    public let topicSend: String?
    public let screenSharer: Bool?
    public let screenshare: String?
    public let screenOwner: ScreenOwner?
    
    public init(topicSend: String?, screenSharer: Bool?, screenshare: String?, screenOwner: ScreenOwner?) {
        self.topicSend = topicSend
        self.screenSharer = screenSharer
        self.screenshare = screenshare
        self.screenOwner = screenOwner
    }

    private enum CodingKeys: String, CodingKey {
        case topicSend = "topicSend"
        case screenSharer = "screenSharer"
        case screenshare = "screenshare"
        case screenOwner = "screenOwner"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.topicSend, forKey: .topicSend)
        try container.encodeIfPresent(self.screenSharer, forKey: .screenSharer)
        try container.encodeIfPresent(self.screenshare, forKey: .screenshare)
        try container.encodeIfPresent(self.screenOwner, forKey: .screenOwner)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.topicSend = try container.decodeIfPresent(String.self, forKey: .topicSend)
        self.screenSharer = try container.decodeIfPresent(Bool.self, forKey: .screenSharer)
        self.screenshare = try container.decodeIfPresent(String.self, forKey: .screenshare)
        self.screenOwner = try container.decode(ScreenOwner.self, forKey: .screenOwner)
    }
}
