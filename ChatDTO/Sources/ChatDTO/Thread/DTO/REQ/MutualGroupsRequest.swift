//
// MutualGroupsRequest.swift
// Copyright (c) 2022 Chat
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
import ChatCore
import ChatModels

public final class MutualGroupsRequest: UniqueIdManagerRequest, ChatSendable {
    public let count: Int
    public let offset: Int
    public let toBeUserVO: Invitee
    public var content: String? { jsonString }
    public var chatMessageType: ChatMessageVOTypes = .mutualGroups

    public init(toBeUser: Invitee, count: Int = 25, offset: Int = 0, uniqueId: String? = nil) {
        self.count = count
        self.offset = offset
        toBeUserVO = toBeUser
        super.init(uniqueId: uniqueId)
    }

    private enum CodingKeys: String, CodingKey {
        case count
        case offset
        case toBeUserVO
        case idType
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encodeIfPresent(count, forKey: .count)
        try? container.encodeIfPresent(offset, forKey: .offset)
        try? container.encodeIfPresent(toBeUserVO, forKey: .toBeUserVO)
    }
}
