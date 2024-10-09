//
// MessageSeenByUsersRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct MessageSeenByUsersRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let messageId: Int
    public let offset: Int
    public let count: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(messageId: Int, count: Int = 25, offset: Int = 0, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.messageId = messageId
        self.offset = offset
        self.count = count
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case messageId
        case offset
        case count
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(messageId, forKey: .messageId)
        try? container.encode(offset, forKey: .offset)
        try? container.encode(count, forKey: .count)
    }
}
