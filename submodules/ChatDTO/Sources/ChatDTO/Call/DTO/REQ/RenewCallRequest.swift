//
// RenewCallRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import ChatModels

public struct RenewCallRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let invitess: [Invitee]
    public let callId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(invitees: [Invitee], callId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        invitess = invitees
        self.callId = callId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case invitess
        case callId
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.invitess, forKey: .invitess)
        try container.encode(self.callId, forKey: .callId)
        try container.encode(self.uniqueId, forKey: .uniqueId)
    }
}
