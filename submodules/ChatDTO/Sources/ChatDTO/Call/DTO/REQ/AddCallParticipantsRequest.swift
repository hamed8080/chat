//
// AddCallParticipantsRequest.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import ChatModels

public struct AddCallParticipantsRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol, Sendable {
    public let callId: Int
    public var contactIds: [Int]?
    public var userNames: [Invitee]?
    public var coreuserIds: [Invitee]?
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(callId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.callId = callId
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    public init(callId: Int, contactIds: [Int], typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.callId = callId
        self.contactIds = contactIds
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    public init(callId: Int, userNames: [String], typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.callId = callId
        var invitess: [Invitee] = []
        userNames.forEach { userame in
            invitess.append(Invitee(id: userame, idType: .username))
        }
        self.userNames = invitess
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    public init(callId: Int, coreUserIds: [Int], typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        self.callId = callId
        var invitess: [Invitee] = []
        coreUserIds.forEach { coreuserId in
            invitess.append(Invitee(id: "\(coreuserId)", idType: .coreUserId))
        }
        coreuserIds = invitess
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        if let contactids = contactIds, contactids.count > 0 {
            try? container.encode(contactids)
        }

        if let coreUserIds = coreuserIds {
            try? container.encode(coreUserIds)
        }

        if let userNames = userNames {
            try? container.encode(userNames)
        }
    }
}
