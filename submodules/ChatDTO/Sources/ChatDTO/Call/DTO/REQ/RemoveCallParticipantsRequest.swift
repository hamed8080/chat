//
// RemoveCallParticipantsRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import ChatModels

public struct RemoveCallParticipantsRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let callId: Int
    public var userIds: [Int]
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(callId: Int, userIds: [Int], typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.callId = callId
        self.userIds = userIds
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        if userIds.count > 0 {
            try? container.encode(userIds)
        }
    }
}
