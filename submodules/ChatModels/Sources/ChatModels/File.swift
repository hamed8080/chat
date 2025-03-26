//
// File.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct File: Codable, Identifiable, Hashable, Sendable {
    public var id: String? { hashCode }
    public var hashCode: String?
    public var name: String?
    public var size: Int?
    public var type: String?

    private enum CodingKeys: String, CodingKey {
        case hashCode
        case name
        case size
        case type
    }

    public init(
        hashCode: String? = nil,
        name: String? = nil,
        size: Int? = nil,
        type: String? = nil
    ) {
        self.hashCode = hashCode
        self.name = name
        self.size = size
        self.type = type
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(hashCode, forKey: .hashCode)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(size, forKey: .size)
        try container.encodeIfPresent(type, forKey: .type)
    }
}
