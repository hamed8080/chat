//
// Invitee.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct Invitee: Codable, Hashable, Sendable {
    public var id: String?
    public var idType: Int?

    public init(id: String?, idType: InviteeTypes?) {
        self.id = id
        self.idType = idType?.rawValue
    }

    public var inviteeTypes: InviteeTypes {
        InviteeTypes(rawValue: idType ?? InviteeTypes.unknown.rawValue) ?? .unknown
    }
}

public extension Invitee {
    var toClass: InviteeClass {
        let idType = InviteeTypes(rawValue: idType ?? InviteeTypes.unknown.rawValue)
        let inviteeClass = InviteeClass(id: id, idType: idType)
        return inviteeClass
    }
}

@objc(InviteeClass)
open class InviteeClass: NSObject, Codable {
    public var id: String?
    public var idType: Int?

    public init(id: String?, idType: InviteeTypes?) {
        self.id = id
        self.idType = idType?.rawValue
    }

    public var inviteeTypes: InviteeTypes {
        InviteeTypes(rawValue: idType ?? InviteeTypes.unknown.rawValue) ?? .unknown
    }
}

public extension InviteeClass {
    var toStruct: Invitee {
        let idType = InviteeTypes(rawValue: idType ?? InviteeTypes.unknown.rawValue)
        let inviteeStruct = Invitee(id: id, idType: idType)
        return inviteeStruct
    }
}

