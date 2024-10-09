//
// BatchDeleteMessageRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct BatchDeleteMessageRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    let threadId: Int
    let deleteForAll: Bool
    let messageIds: [Int]
    public let uniqueIds: [String]
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(threadId: Int, messageIds: [Int], deleteForAll: Bool = false, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.threadId = threadId
        self.deleteForAll = deleteForAll
        self.uniqueIds = messageIds.map{_ in UUID().uuidString}
        self.messageIds = messageIds
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case deleteForAll
        case ids
        case uniqueIds
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageIds, forKey: .ids)
        try container.encode(deleteForAll, forKey: .deleteForAll)
        try container.encode(uniqueIds, forKey: .uniqueIds)
    }
}
