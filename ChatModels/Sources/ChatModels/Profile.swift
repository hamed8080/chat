//
// Profile.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/2/22

import Foundation

open class Profile: Codable {
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

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        metadata = try container.decodeIfPresent(String.self, forKey: .metadata)
    }
}
