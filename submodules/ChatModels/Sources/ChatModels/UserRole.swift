//
// UserRole.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct UserRole: Codable, Hashable, Identifiable, Sendable {
    public var threadId: Int?
    public var roles: [Roles]?
    public var id: Int?
    public var name: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        roles = try container.decodeIfPresent([Roles].self, forKey: .roles)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
    }

    public init(threadId: Int? = nil, id: Int? = nil, name: String? = nil, roles: [Roles]? = nil) {
        self.name = name
        self.id = id
        self.roles = roles
        self.threadId = threadId
    }

    private enum CodingKeys: String, CodingKey {
        case roles
        case id
        case name
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(roles, forKey: .roles)
    }
}
