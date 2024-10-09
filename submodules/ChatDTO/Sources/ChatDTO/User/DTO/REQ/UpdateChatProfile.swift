//
// UpdateChatProfile.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct UpdateChatProfile: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let bio: String?
    public let metadata: String?
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(bio: String?, metadata: String? = nil, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.bio = bio
        self.metadata = metadata
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case bio
        case metadata
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encodeIfPresent(metadata, forKey: .metadata)
    }
}
