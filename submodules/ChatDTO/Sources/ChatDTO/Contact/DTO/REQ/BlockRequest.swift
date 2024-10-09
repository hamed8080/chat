//
// BlockRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct BlockRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let contactId: Int?
    public let threadId: Int?
    public let userId: Int?
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(contactId: Int? = nil,
                threadId: Int? = nil,
                userId: Int? = nil,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
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
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(contactId, forKey: .contactId)
        try? container.encodeIfPresent(threadId, forKey: .threadId)
        try? container.encodeIfPresent(userId, forKey: .userId)
    }
}
