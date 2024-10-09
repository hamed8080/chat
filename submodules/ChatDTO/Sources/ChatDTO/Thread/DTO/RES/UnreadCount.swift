//
// UnreadCount.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct UnreadCount: Decodable {
    public let unreadCount: Int?
    public let threadId: Int?

    public init(unreadCount: Int?, threadId: Int?) {
        self.unreadCount = unreadCount
        self.threadId = threadId
    }

    private enum CodingKeys: CodingKey {
        case unreadCount
        case threadId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.unreadCount = try container.decodeIfPresent(Int.self, forKey: .unreadCount)
        self.threadId = try container.decodeIfPresent(Int.self, forKey: .threadId)
    }
}
