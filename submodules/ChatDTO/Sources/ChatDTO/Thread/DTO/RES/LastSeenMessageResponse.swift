//
// LastSeenMessageResponse.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct LastSeenMessageResponse: Decodable {
    public let id: Int?
    public let unreadCount: Int?
    public let lastSeenMessageTime: UInt?
    public let lastSeenMessageId: Int?
    public let lastSeenMessageNanos: UInt?

    private enum CodingKeys: CodingKey {
        case id
        case unreadCount
        case lastSeenMessageTime
        case lastSeenMessageId
        case lastSeenMessageNanos
    }

    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        id = try container?.decodeIfPresent(Int.self, forKey: .id)
        unreadCount = try container?.decodeIfPresent(Int.self, forKey: .unreadCount) ?? 0
        lastSeenMessageTime = try container?.decodeIfPresent(UInt.self, forKey: .lastSeenMessageTime)
        lastSeenMessageId = try container?.decodeIfPresent(Int.self, forKey: .lastSeenMessageId)
        lastSeenMessageNanos = try container?.decodeIfPresent(UInt.self, forKey: .lastSeenMessageNanos)
    }

    public init(
        id: Int? = nil,
        unreadCount: Int? = nil,
        lastSeenMessageTime: UInt? = nil,
        lastSeenMessageId: Int? = nil,
        lastSeenMessageNanos: UInt? = nil) {
            self.id = id
            self.unreadCount = unreadCount
            self.lastSeenMessageTime = lastSeenMessageTime
            self.lastSeenMessageId = lastSeenMessageId
            self.lastSeenMessageNanos = lastSeenMessageNanos
        }
}
