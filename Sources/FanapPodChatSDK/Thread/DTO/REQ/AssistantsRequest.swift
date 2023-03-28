//
// AssistantsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation

public final class AssistantsRequest: UniqueIdManagerRequest, ChatSendable {
    public let contactType: String
    public let count: Int
    public let offset: Int
    var chatMessageType: ChatMessageVOTypes = .getAssistants
    var content: String? { convertCodableToString() }

    public init(contactType: String,
                count: Int = 50,
                offset: Int = 0,
                uniqueId: String? = nil)
    {
        self.contactType = contactType
        self.count = count
        self.offset = offset
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case contactType
        case count
        case offset
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(contactType, forKey: .contactType)
        try container.encodeIfPresent(count, forKey: .count)
        try container.encodeIfPresent(offset, forKey: .offset)
    }
}
