//
// SafeLeaveThreadRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct SafeLeaveThreadRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let threadId: Int
    public let clearHistory: Bool?
    public let uniqueId: String
    public let participantId: Int
    public var typeCodeIndex: Index

    public init(threadId: Int, participantId: Int, clearHistory: Bool? = false, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.participantId = participantId
        self.clearHistory = clearHistory
        self.threadId = threadId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case clearHistory
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(clearHistory, forKey: .clearHistory)
    }
}
