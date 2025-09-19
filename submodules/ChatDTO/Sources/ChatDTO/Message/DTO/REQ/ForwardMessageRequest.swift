//
// ForwardMessageRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct ForwardMessageRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public var queueTime: Date = .init()
    public let messageIds: [Int]
    public let fromThreadId: Int
    public var threadId: Int
    public var uniqueIds: [String]
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(fromThreadId: Int, threadId: Int, messageIds: [Int], typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.fromThreadId = fromThreadId
        self.threadId = threadId
        self.messageIds = messageIds
        self.uniqueIds = messageIds.map{_ in UUID().uuidString}
        self.uniqueId = "\(self.uniqueIds)"
        self.typeCodeIndex = typeCodeIndex
    }

    internal init(fromThreadId: Int, threadId: Int, messageIds: [Int], uniqueIds: [String], typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.fromThreadId = fromThreadId
        self.threadId = threadId
        self.messageIds = messageIds
        self.uniqueIds = uniqueIds
        self.uniqueId = "\(self.uniqueIds)"
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case queueTime
        case messageIds
        case fromThreadId
        case threadId
        case uniqueIds
        case typeCode
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.queueTime, forKey: .queueTime)
        try container.encode(self.messageIds, forKey: .messageIds)
        try container.encode(self.fromThreadId, forKey: .fromThreadId)
        try container.encode(self.threadId, forKey: .threadId)
        try container.encode(self.uniqueIds, forKey: .uniqueIds)
//        try container.encodeIfPresent(self.typeCode, forKey: .typeCode)
        try container.encode(self.uniqueId, forKey: .uniqueId)
    }
}
