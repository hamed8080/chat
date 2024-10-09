//
// Tag.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct Tag: Codable, Hashable, Identifiable {
    public var id: Int
    public var name: String
    public var active: Bool
    public var tagParticipants: [TagParticipant]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        active = try container.decode(Bool.self, forKey: .active)
        tagParticipants = try container.decodeIfPresent([TagParticipant].self, forKey: .tagParticipants)
    }

    public init(
        id: Int,
        name: String,
        active: Bool,
        tagParticipants: [TagParticipant]? = nil
    ) {
        self.id = id
        self.name = name
        self.active = active
        self.tagParticipants = tagParticipants
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case active
        case tagParticipants = "tagParticipantVOList"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(active, forKey: .active)
    }
}
