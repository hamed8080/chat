//
// EditTagRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct EditTagRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public var name: String
    public var id: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(id: Int, tagName: String, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.id = id
        name = tagName
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case name
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(name, forKey: .name)
    }
}
