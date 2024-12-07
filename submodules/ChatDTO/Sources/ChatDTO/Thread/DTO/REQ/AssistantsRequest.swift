//
// AssistantsRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct AssistantsRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let contactType: String
    public let count: Int
    public let offset: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(contactType: String = "default", count: Int = 25, offset: Int = 0, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.contactType = contactType
        self.count = count
        self.offset = offset
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case contactType
        case count
        case offset
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(contactType, forKey: .contactType)
        try container.encodeIfPresent(count, forKey: .count)
        try container.encodeIfPresent(offset, forKey: .offset)
    }
}
