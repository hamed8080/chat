//
// MessageSeenRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct MessageSeenRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let messageId: Int
    public let threadId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(threadId: Int, messageId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.messageId = messageId
        self.threadId = threadId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case messageId
        case threadId
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.messageId, forKey: .messageId)
        try container.encode(self.threadId, forKey: .threadId)
        try container.encode(self.uniqueId, forKey: .uniqueId)
    }
}
