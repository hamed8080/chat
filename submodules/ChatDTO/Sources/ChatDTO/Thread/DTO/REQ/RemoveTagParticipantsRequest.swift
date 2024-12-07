//
// RemoveTagParticipantsRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct RemoveTagParticipantsRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public var tagId: Int
    public var tagParticipants: [TagParticipant]
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(tagId: Int, tagParticipants: [TagParticipant], typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.tagId = tagId
        self.tagParticipants = tagParticipants
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case tagId
        case tagParticipants
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.tagId, forKey: .tagId)
        try container.encode(self.tagParticipants, forKey: .tagParticipants)
        try container.encode(self.uniqueId, forKey: .uniqueId)
    }
}
