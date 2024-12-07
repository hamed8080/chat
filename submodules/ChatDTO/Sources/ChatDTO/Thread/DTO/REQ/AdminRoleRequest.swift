//
// AdminRoleRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct AdminRoleRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let invitees: [Invitee]
    public let conversationId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(participants: [Invitee], conversationId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.invitees = participants
        self.conversationId = conversationId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case invitees
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(invitees, forKey: .invitees)
    }
}
