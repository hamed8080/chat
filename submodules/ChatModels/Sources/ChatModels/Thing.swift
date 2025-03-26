//
// Thing.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct Thing: Codable, Hashable, Sendable {
    public var id: Int? // its thing id of relevant thing of this bot in SSO
    public var name: String? // bot name
    public var title: String? // bot name
    public var type: String? // it must be Bot
    public var bot: Bool?
    public var active: Bool?
    public var chatSendEnable: Bool?
    public var chatReceiveEnable: Bool?
    public var owner: Participant?
    public var creator: Participant?

    public init(id: Int? = nil, name: String? = nil, title: String? = nil, type: String? = nil, bot: Bool? = nil, active: Bool? = nil, chatSendEnable: Bool? = nil, chatReceiveEnable: Bool? = nil, owner: Participant? = nil, creator: Participant? = nil) {
        self.id = id
        self.name = name
        self.title = title
        self.type = type
        self.bot = bot
        self.active = active
        self.chatSendEnable = chatSendEnable
        self.chatReceiveEnable = chatReceiveEnable
        self.owner = owner
        self.creator = creator
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.bot = try container.decodeIfPresent(Bool.self, forKey: .bot)
        self.active = try container.decodeIfPresent(Bool.self, forKey: .active)
        self.chatSendEnable = try container.decodeIfPresent(Bool.self, forKey: .chatSendEnable)
        self.chatReceiveEnable = try container.decodeIfPresent(Bool.self, forKey: .chatReceiveEnable)
        self.owner = try container.decodeIfPresent(Participant.self, forKey: .owner)
        self.creator = try container.decodeIfPresent(Participant.self, forKey: .creator)
    }

    private enum CodingKeys: CodingKey {
        case id
        case name
        case title
        case type
        case bot
        case active
        case chatSendEnable
        case chatReceiveEnable
        case owner
        case creator
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.title, forKey: .title)
        try container.encodeIfPresent(self.type, forKey: .type)
        try container.encodeIfPresent(self.bot, forKey: .bot)
        try container.encodeIfPresent(self.active, forKey: .active)
        try container.encodeIfPresent(self.chatSendEnable, forKey: .chatSendEnable)
        try container.encodeIfPresent(self.chatReceiveEnable, forKey: .chatReceiveEnable)
        try container.encodeIfPresent(self.owner, forKey: .owner)
        try container.encodeIfPresent(self.creator, forKey: .creator)
    }
}
