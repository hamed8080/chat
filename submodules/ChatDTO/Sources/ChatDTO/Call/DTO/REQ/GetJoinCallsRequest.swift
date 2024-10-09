//
// GetJoinCallsRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import ChatModels

public struct GetJoinCallsRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let offset: Int
    public let count: Int
    public let name: String?
    public let type: CallType?
    public let threadIds: [Int]
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(threadIds: [Int],
                offset: Int = 0,
                count: Int = 50,
                name: String? = nil,
                type: CallType? = nil,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        self.offset = offset
        self.count = count
        self.name = name
        self.type = type
        self.threadIds = threadIds
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case offset
        case count
        case name
        case type
        case threadIds
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(offset, forKey: .offset)
        try container.encodeIfPresent(count, forKey: .count)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(threadIds, forKey: .threadIds)
    }
}
