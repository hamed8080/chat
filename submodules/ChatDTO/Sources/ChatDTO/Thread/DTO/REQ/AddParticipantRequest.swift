//
// AddParticipantRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation
import ChatModels

public struct AddParticipantRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    private var invitees: [Invitee]?
    public var threadId: Int
    public var contactIds: [Int]?
    public var coreUserIds: [Int]?
    public var userNames: [String]?
    public let uniqueId: String
    public var typeCodeIndex: Index
    
    /// Only use "username" and "coreUserId" as a type to add participants.
    /// If you want to limit new users' historyTime use the provided property inside an Invitee.
    public init(invitees: [Invitee], threadId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.threadId = threadId
        self.invitees = invitees
        self.threadId = threadId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    public init(userNames: [String], threadId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        invitees = userNames.map { .init(id: $0, idType : .username) }
        self.threadId = threadId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    public init(coreUserIds: [Int], threadId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        invitees = coreUserIds.map { .init(id: "\($0)", idType : .coreUserId) }
        self.threadId = threadId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    public init(contactIds: [Int], threadId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.contactIds = contactIds
        self.threadId = threadId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    public func encode(to encoder: Encoder) throws {
        if let invitees = invitees {
            var container = encoder.unkeyedContainer()
            try? container.encode(contentsOf: invitees)
        } else if let contactIds = contactIds {
            var container = encoder.unkeyedContainer()
            try? container.encode(contentsOf: contactIds)
        }
    }
}
