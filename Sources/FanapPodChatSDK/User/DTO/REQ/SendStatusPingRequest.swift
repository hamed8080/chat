//
// SendStatusPingRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation

public enum StatusPingType: Int, Encodable {
    case chat
    case thread
    case contacts
    case threadId
    case contactId
}

public class SendStatusPingRequest: UniqueIdManagerRequest, ChatSnedable {
    public let statusType: StatusPingType
    public let id: Int?
    var chatMessageType: ChatMessageVOTypes = .statusPing
    var content: String? { convertCodableToString() }

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
