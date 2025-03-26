//
// CreateCall.swift
// Copyright (c) 2022 ChatDTO
//
// Created by Hamed Hosseini on 12/16/22

import Foundation
import ChatModels

public struct CreateCall: Codable, Sendable {
    public let invitees: [Invitee]?
    public let type: CallType
    public let creatorId: Int
    public let creator: Participant
    public let conversation: Conversation?
    public let threadId: Int
    public let callId: Int
    public let group: Bool

    public init(invitees: [Invitee]? = nil, type: CallType, creatorId: Int, creator: Participant, conversation: Conversation? = nil, threadId: Int, callId: Int, group: Bool) {
        self.invitees = invitees
        self.type = type
        self.creatorId = creatorId
        self.creator = creator
        self.conversation = conversation
        self.threadId = threadId
        self.callId = callId
        self.group = group
    }

    private enum CodingKeys: String, CodingKey {
        case invitees
        case type
        case creatorId
        case creator = "creatorVO"
        case conversation = "conversationVO"
        case threadId
        case callId
        case group
    }

    public var title: String? {
        conversation?.title ?? creator.name
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.invitees, forKey: .invitees)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.creatorId, forKey: .creatorId)
        try container.encode(self.creator, forKey: .creator)
        try container.encodeIfPresent(self.conversation, forKey: .conversation)
        try container.encode(self.threadId, forKey: .threadId)
        try container.encode(self.callId, forKey: .callId)
        try container.encode(self.group, forKey: .group)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.invitees = try container.decodeIfPresent([Invitee].self, forKey: .invitees)
        self.type = try container.decode(CallType.self, forKey: .type)
        self.creatorId = try container.decode(Int.self, forKey: .creatorId)
        self.creator = try container.decode(Participant.self, forKey: .creator)
        self.conversation = try container.decodeIfPresent(Conversation.self, forKey: .conversation)
        self.threadId = try container.decode(Int.self, forKey: .threadId)
        self.callId = try container.decode(Int.self, forKey: .callId)
        self.group = try container.decode(Bool.self, forKey: .group)
    }
}
