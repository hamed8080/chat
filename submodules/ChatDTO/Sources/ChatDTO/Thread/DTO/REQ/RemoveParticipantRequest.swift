//
// RemoveParticipantRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct RemoveParticipantRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let participantIds: [Int]?
    public let invitees: [Invitee]?
    public let threadId: Int
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(participantId: Int, threadId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.threadId = threadId
        participantIds = [participantId]
        self.uniqueId = UUID().uuidString
        invitees = nil
        self.typeCodeIndex = typeCodeIndex
    }

    public init(participantIds: [Int], threadId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.threadId = threadId
        self.participantIds = participantIds
        self.uniqueId = UUID().uuidString
        invitees = nil
        self.typeCodeIndex = typeCodeIndex
    }

    public init(invitess: [Invitee], threadId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.threadId = threadId
        self.invitees = invitess
        self.uniqueId = UUID().uuidString
        participantIds = nil
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: CodingKey {
        case participantIds
        case invitees
        case threadId
        case uniqueId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(participantIds, forKey: .participantIds)
        try container.encodeIfPresent(invitees, forKey: .invitees)
        try container.encode(threadId, forKey: .threadId)
        try container.encode(uniqueId, forKey: .uniqueId)
    }
}
