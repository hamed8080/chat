//
// TagParticipant.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct TagParticipant: Codable, Hashable, Identifiable {
    public var id: Int?
    public var active: Bool?
    public var tagId: Int?
    public var threadId: Int?
    public var conversation: Conversation?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        active = try container.decodeIfPresent(Bool.self, forKey: .active)
        tagId = try container.decodeIfPresent(Int.self, forKey: .tagId)
        conversation = try? container.decodeIfPresent(Conversation.self, forKey: .conversation)
        threadId = try? container.decodeIfPresent(Int.self, forKey: .threadId)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
    }

    public init(
        id: Int? = nil,
        active: Bool? = nil,
        tagId: Int? = nil,
        threadId: Int? = nil,
        conversation: Conversation? = nil
    ) {
        self.id = id
        self.active = active
        self.tagId = tagId
        self.threadId = threadId
        self.conversation = conversation
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case active
        case tagId
        case threadId
        case conversation = "conversationVO"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(active, forKey: .active)
        try container.encodeIfPresent(tagId, forKey: .tagId)
        try container.encodeIfPresent(threadId, forKey: .threadId)
    }
}
