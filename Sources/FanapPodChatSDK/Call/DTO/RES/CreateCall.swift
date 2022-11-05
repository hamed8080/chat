//
// CreateCall.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public struct CreateCall: Codable {
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
}
