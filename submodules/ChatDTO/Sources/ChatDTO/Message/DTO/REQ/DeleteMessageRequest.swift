//
// DeleteMessageRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct DeleteMessageRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let deleteForAll: Bool
    public let messageId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(deleteForAll: Bool? = false, messageId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.deleteForAll = deleteForAll ?? false
        self.messageId = messageId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case deleteForAll
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(deleteForAll, forKey: .deleteForAll)
    }
}
