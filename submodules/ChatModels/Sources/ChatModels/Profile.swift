//
// Profile.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct Profile: Codable, Hashable, Sendable {
    public var bio: String?
    public var metadata: String?

    public init(bio: String?, metadata: String?) {
        self.bio = bio
        self.metadata = metadata
    }

    private enum CodingKeys: String, CodingKey {
        case bio
        case metadata
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
    }
}
