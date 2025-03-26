//
// ForwardInfoConversation.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct ForwardInfoConversation: Codable, Hashable, Sendable {
    public var description: String?
    public var group: Bool?
    public var id: Int?
    public var image: String?
    public var metadata: String?
    public var participantCount: Int?
    public var title: String?
    public var type: ThreadTypes?
    public var uniqueName: String?
    public var userGroupHash: String?

    public init(description: String? = nil, group: Bool? = nil, id: Int? = nil, image: String? = nil, metadata: String? = nil, participantCount: Int? = nil, title: String? = nil, type: ThreadTypes? = nil, uniqueName: String? = nil, userGroupHash: String? = nil) {
        self.description = description
        self.group = group
        self.id = id
        self.image = image
        self.metadata = metadata
        self.participantCount = participantCount
        self.title = title
        self.type = type
        self.uniqueName = uniqueName
        self.userGroupHash = userGroupHash
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.group = try container.decodeIfPresent(Bool.self, forKey: .group)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        self.metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
        self.participantCount = try container.decodeIfPresent(Int.self, forKey: .participantCount)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.type = try container.decodeIfPresent(ThreadTypes.self, forKey: .type)
        self.uniqueName = try container.decodeIfPresent(String.self, forKey: .uniqueName)
        self.userGroupHash = try container.decodeIfPresent(String.self, forKey: .userGroupHash)
    }

    enum CodingKeys: CodingKey {
        case description
        case group
        case id
        case image
        case metadata
        case participantCount
        case title
        case type
        case uniqueName
        case userGroupHash
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encodeIfPresent(self.group, forKey: .group)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.image, forKey: .image)
        try container.encodeIfPresent(self.metadata, forKey: .metadata)
        try container.encodeIfPresent(self.participantCount, forKey: .participantCount)
        try container.encodeIfPresent(self.title, forKey: .title)
        try container.encodeIfPresent(self.type, forKey: .type)
        try container.encodeIfPresent(self.uniqueName, forKey: .uniqueName)
        try container.encodeIfPresent(self.userGroupHash, forKey: .userGroupHash)
    }
}

public extension Conversation {
    var toForwardConversation: ForwardInfoConversation {
        let fc = ForwardInfoConversation(description: description,
                                         group: group,
                                         id: id,
                                         image: image,
                                         metadata: metadata,
                                         participantCount: participantCount,
                                         title: title,
                                         type: type,
                                         uniqueName: uniqueName,
                                         userGroupHash: userGroupHash)
        return fc
    }
}
