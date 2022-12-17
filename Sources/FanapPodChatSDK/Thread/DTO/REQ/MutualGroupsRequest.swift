//
// MutualGroupsRequest.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 11/19/22

import Foundation
public class MutualGroupsRequest: UniqueIdManagerRequest, ChatSendable {
    internal let count: Int
    internal let offset: Int
    internal let toBeUserVO: Invitee
    var content: String? { convertCodableToString() }
    var chatMessageType: ChatMessageVOTypes = .mutualGroups

    public init(toBeUser: Invitee, count: Int = 50, offset: Int = 0, uniqueId: String? = nil) {
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
