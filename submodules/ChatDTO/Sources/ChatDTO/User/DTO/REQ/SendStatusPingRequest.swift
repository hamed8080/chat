//
// StatusPingType.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public enum StatusPingType: Int, Encodable, Identifiable, CaseIterable {
    public var id: Self { self }
    case chat
    case thread
    case contacts
    case threadId
    case contactId
}

public struct SendStatusPingRequest: Encodable, UniqueIdProtocol, TypeCodeIndexProtocol {
    public let statusType: StatusPingType
    public let id: Int?
    public let uniqueId: String
    public var typeCodeIndex: Index

    public init(statusType: StatusPingType, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        id = nil
        self.statusType = statusType
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    public init(statusType: StatusPingType, contactId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        id = contactId
        self.statusType = statusType
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    public init(statusType: StatusPingType, threadId: Int, typeCodeIndex: TypeCodeIndexProtocol.Index = 0) {
        id = threadId
        self.statusType = statusType
        self.uniqueId = UUID().uuidString
        self.typeCodeIndex = typeCodeIndex
    }

    private enum CodingKeys: String, CodingKey {
        case location
        case locationId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if statusType == .chat {
            try container.encode(1, forKey: .location)
        } else if statusType == .contacts || statusType == .contactId {
            try container.encode(3, forKey: .location)
        } else if statusType == .thread || statusType == .threadId {
            try container.encode(2, forKey: .location)
        }
        try container.encodeIfPresent(id, forKey: .locationId)
    }
}
