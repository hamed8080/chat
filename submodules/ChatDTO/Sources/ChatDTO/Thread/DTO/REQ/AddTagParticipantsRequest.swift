//
// AddTagParticipantsRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct AddTagParticipantsRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public var tagId: Int
    public var threadIds: [Int]
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(tagId: Int, threadIds: [Int], typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.threadIds = threadIds
        self.tagId = tagId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case tagId
        case threadIds
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.tagId, forKey: .tagId)
        try container.encode(self.threadIds, forKey: .threadIds)
        try container.encode(self.uniqueId, forKey: .uniqueId)
    }
}
