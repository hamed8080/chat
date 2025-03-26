//
// PinUnpinMessageRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct PinUnpinMessageRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let messageId: Int
    public let notifyAll: Bool
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(messageId: Int, notifyAll: Bool = false, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.messageId = messageId
        self.notifyAll = notifyAll
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case notifyAll
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(notifyAll, forKey: .notifyAll)
    }
}
