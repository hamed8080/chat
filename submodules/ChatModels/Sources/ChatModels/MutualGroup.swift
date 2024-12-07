//
// MutualGroup.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct MutualGroup: Codable, Hashable, Sendable {
    public var mutualId: String?
    public var idType: InviteeTypes?
    public var conversations: [Conversation]?

    private enum CodingKeys: String, CodingKey {
        case mutualId
        case conversations
    }

    public init(from _: Decoder) throws {}

    public init(idType: InviteeTypes, mutualId: String?, conversations: [Conversation]? = nil) {
        self.mutualId = mutualId
        self.idType = idType
        self.conversations = conversations
    }

    public func encode(to _: Encoder) throws {}
}
