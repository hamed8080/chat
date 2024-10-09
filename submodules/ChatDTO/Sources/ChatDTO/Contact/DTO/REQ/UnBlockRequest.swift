//
// UnBlockRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct UnBlockRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let blockId: Int?
    public let contactId: Int?
    public let threadId: Int?
    public let userId: Int?
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(blockId: Int? = nil,
                contactId: Int? = nil,
                threadId: Int? = nil,
                userId: Int? = nil,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        self.blockId = blockId
        self.contactId = contactId
        self.threadId = threadId
        self.userId = userId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case contactId
        case threadId
        case userId
        case blockId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(blockId, forKey: .blockId)
        try? container.encodeIfPresent(contactId, forKey: .contactId)
        try? container.encodeIfPresent(threadId, forKey: .threadId)
        try? container.encodeIfPresent(userId, forKey: .userId)
    }
}
