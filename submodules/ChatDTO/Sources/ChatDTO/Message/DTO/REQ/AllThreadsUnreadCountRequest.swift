//
// AllThreadsUnreadCountRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct AllThreadsUnreadCountRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    let mute: Bool
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(mute: Bool = false, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.mute = mute
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case mute
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mute, forKey: .mute)
    }
}
