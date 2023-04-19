//
// SendStatusPingRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore

public enum StatusPingType: Int, Encodable, Identifiable, CaseIterable {
    public var id: Self { self }
    case chat
    case thread
    case contacts
    case threadId
    case contactId
}

public final class SendStatusPingRequest: UniqueIdManagerRequest, ChatSendable {
    public let statusType: StatusPingType
    public let id: Int?
    public var chatMessageType: ChatMessageVOTypes = .statusPing
    public var content: String? { jsonString }

    public init(statusType: StatusPingType, uniqueId: String? = nil) {
        id = nil
        self.statusType = statusType
        super.init(uniqueId: uniqueId)
    }

    public init(statusType: StatusPingType, contactId: Int, uniqueId: String? = nil) {
        id = contactId
        self.statusType = statusType
        super.init(uniqueId: uniqueId)
    }

    public init(statusType: StatusPingType, threadId: Int, uniqueId: String? = nil) {
        id = threadId
        self.statusType = statusType
        super.init(uniqueId: uniqueId)
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
