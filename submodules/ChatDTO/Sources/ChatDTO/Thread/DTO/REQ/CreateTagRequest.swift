//
// CreateTagRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct CreateTagRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public var name: String
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(tagName: String, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        name = tagName
        uniqueId = UUID().uuidString
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
