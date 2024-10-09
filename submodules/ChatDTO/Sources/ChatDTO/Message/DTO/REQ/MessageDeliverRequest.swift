//
// MessageDeliverRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct MessageDeliverRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let messageId: String
    public let threadId: Int?
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(messageId: Int, threadId: Int?, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.messageId = "\(messageId)"
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
        try container.encodeIfPresent(self.threadId, forKey: .threadId)
        try container.encode(self.uniqueId, forKey: .uniqueId)
    }
}
