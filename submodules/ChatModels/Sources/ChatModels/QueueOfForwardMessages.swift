//
// QueueOfForwardMessages.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct QueueOfForwardMessages: Codable, Hashable, Identifiable {
    public var id: String? { uniqueIds?.joined(separator: ",") }
    public var fromThreadId: Int?
    public var messageIds: [Int]?
    public var threadId: Int?
    public var typeCode: String?
    public var uniqueIds: [String]?

    private enum CodingKeys: String, CodingKey {
        case fromThreadId
        case messageIds
        case threadId
        case typeCode
        case uniqueIds
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fromThreadId = try container.decodeIfPresent(Int.self, forKey: .fromThreadId)
        messageIds = try container.decodeIfPresent([Int].self, forKey: .messageIds)
        threadId = try container.decodeIfPresent(Int.self, forKey: .threadId)
        typeCode = try container.decodeIfPresent(String.self, forKey: .typeCode)
    }

    public init(
        fromThreadId: Int? = nil,
        messageIds: [Int]? = nil,
        threadId: Int? = nil,
        typeCode: String? = nil,
        uniqueIds: [String]? = nil
    ) {
        self.fromThreadId = fromThreadId
        self.messageIds = messageIds
        self.threadId = threadId
        self.typeCode = typeCode
        self.uniqueIds = uniqueIds
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(fromThreadId, forKey: .fromThreadId)
        try container.encodeIfPresent(messageIds, forKey: .messageIds)
        try container.encodeIfPresent(threadId, forKey: .threadId)
        try container.encodeIfPresent(typeCode, forKey: .typeCode)
        try container.encodeIfPresent(uniqueIds, forKey: .uniqueIds)
    }
}
