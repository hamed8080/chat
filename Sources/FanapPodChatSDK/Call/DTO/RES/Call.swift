//
// Call.swift
// Copyright (c) 2022 FanapPodChatSDK
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
public struct Call: Codable, Equatable {
    public static func == (lhs: Call, rhs: Call) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public let id: Int
    public let creatorId: Int
    public let type: CallType
    public let createTime: Int?
    public let startTime: Int?
    public let endTime: Int?
    public let status: CallStatus?
    public let isGroup: Bool
    public let callParticipants: [Participant]?
    public let partnerParticipant: Participant?
    public let conversation: Conversation?

    public func isIncomingCall(currentUserId: Int?) -> Bool {
        creatorId != currentUserId
    }

    public init(id: Int,
                creatorId: Int,
                type: CallType,
                isGroup: Bool,
                createTime: Int? = nil,
                startTime: Int? = nil,
                endTime: Int? = nil,
                status: CallStatus? = nil,
                callParticipants: [Participant]? = nil,
                partnerParticipant: Participant? = nil,
                conversation: Conversation? = nil)
    {
        self.id = id
        self.creatorId = creatorId
        self.type = type
        self.createTime = createTime
        self.startTime = startTime
        self.endTime = endTime
        self.status = status
        self.isGroup = isGroup
        self.callParticipants = callParticipants
        self.partnerParticipant = partnerParticipant
        self.conversation = conversation
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case creatorId
        case type
        case createTime
        case startTime
        case endTime
        case status
        case isGroup = "group"
        case callParticipants
        case partnerParticipant = "partnerParticipantVO"
        case conversation = "conversationVO"
    }
}
