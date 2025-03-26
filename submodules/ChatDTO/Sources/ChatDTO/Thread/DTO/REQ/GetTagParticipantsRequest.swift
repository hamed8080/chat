//
// GetTagParticipantsRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct GetTagParticipantsRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public var id: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(id: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.id = id
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case id
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.uniqueId, forKey: .uniqueId)
    }
}
