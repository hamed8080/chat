//
// CallsHistoryRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public class CallsHistoryRequest: UniqueIdManagerRequest, ChatSendable {
    public let count: Int
    public let offset: Int
    public let callIds: [Int]?
    public let type: CallType?
    public let name: String?
    public let creatorCoreUserId: Int?
    public let creatorSsoId: Int?
    public let threadId: Int?
    var content: String? { convertCodableToString() }
    var chatMessageType: ChatMessageVOTypes = .getCalls

    public init(count: Int = 50,
                offset: Int = 0,
                callIds: [Int]? = nil,
                type: CallType? = nil,
                name: String? = nil,
                creatorCoreUserId: Int? = nil,
                creatorSsoId: Int? = nil,
                threadId: Int? = nil)
    {
        self.count = count
        self.offset = offset
        self.callIds = callIds
        self.type = type
        self.name = name
        self.creatorCoreUserId = creatorCoreUserId
        self.creatorSsoId = creatorSsoId
        self.threadId = threadId
    }

    private enum CodingKeys: String, CodingKey {
        case count
        case offset
        case callIds
        case type
        case name
        case creatorCoreUserId
        case creatorSsoId
        case threadId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(count, forKey: .count)
        try container.encode(offset, forKey: .offset)
        try container.encodeIfPresent(callIds, forKey: .callIds)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(creatorSsoId, forKey: .creatorSsoId)
        try container.encodeIfPresent(creatorCoreUserId, forKey: .creatorCoreUserId)
        try container.encodeIfPresent(threadId, forKey: .threadId)
    }
}
