//
// MentionRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct MentionRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public var count: Int = 25
    public var offset: Int = 0
    public let threadId: Int
    public let onlyUnreadMention: Bool
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(threadId: Int,
                onlyUnreadMention: Bool,
                count: Int = 25,
                offset: Int = 0,
                typeCodeIndex: TypeCodeIndexProtocol.Index = 0)
    {
        self.count = count
        self.offset = offset
        self.threadId = threadId
        self.onlyUnreadMention = onlyUnreadMention
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case count
        case offset
        case unreadMentioned
        case allMentioned
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(count, forKey: .count)
        try container.encode(offset, forKey: .offset)
        if onlyUnreadMention {
            try container.encode(true, forKey: .unreadMentioned)
        } else {
            try container.encode(true, forKey: .allMentioned)
        }
    }
}
