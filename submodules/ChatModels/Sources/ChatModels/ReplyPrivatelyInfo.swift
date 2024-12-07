//
// ReplyPrivatelyInfo.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct ReplyPrivatelyInfo: Codable, Hashable, Sendable {
    public var threadId: Int?
    public var threadName: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        threadId = try container.decodeIfPresent(Int.self, forKey: .threadId)
        threadName = try container.decodeIfPresent(String.self, forKey: .threadName)
    }

    public init(threadId: Int? = nil, threadName: String? = nil) {
        self.threadId = threadId
        self.threadName = threadName
    }

    private enum CodingKeys: String, CodingKey {
        case threadId
        case threadName
    }
}
