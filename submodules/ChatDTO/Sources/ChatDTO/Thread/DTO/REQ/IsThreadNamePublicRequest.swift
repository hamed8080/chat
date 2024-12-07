//
// IsThreadNamePublicRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct IsThreadNamePublicRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let name: String
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(name: String, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.name = name
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
