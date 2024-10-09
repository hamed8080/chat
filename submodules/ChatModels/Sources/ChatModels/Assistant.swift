//
// Assistant.swift
// Copyright (c) 2022 ChatModels
//
// Created by Hamed Hosseini on 12/14/22

import Foundation

public struct Assistant: Codable, Identifiable, Hashable {
    public static func == (lhs: Assistant, rhs: Assistant) -> Bool {
        lhs.id == rhs.id &&
        lhs.contactType == rhs.contactType &&
        lhs.assistant == rhs.assistant &&
        lhs.participant == rhs.participant &&
        lhs.roles == rhs.roles &&
        lhs.block == rhs.block
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(contactType)
        hasher.combine(assistant)
        hasher.combine(participant)
        hasher.combine(roles)
        hasher.combine(block)
    }

    public var id: Int?
    public var contactType: String?
    public var assistant: Invitee?
    public var participant: Participant?
    public var roles: [Roles]?
    public var block: Bool?

    public init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        contactType = try container?.decodeIfPresent(String.self, forKey: .contactType)
        assistant = try container?.decodeIfPresent(Invitee.self, forKey: .assistant)
        participant = try container?.decodeIfPresent(Participant.self, forKey: .participantVO)
        roles = try container?.decodeIfPresent([Roles].self, forKey: .roles)
        block = (try container?.decodeIfPresent(Bool.self, forKey: .block)) ?? false
    }

    public init(id: Int? = nil, contactType: String? = "default", assistant: Invitee? = nil, participant: Participant? = nil, roles: [Roles]? = nil, block: Bool? = nil) {
        self.id = id
        self.contactType = contactType
        self.assistant = assistant
        self.participant = participant
        self.roles = roles
        self.block = block
    }

    /// For registering an assistant.
    public init(contactType: String? = "default", assistant: Invitee, roles: [Roles]) {
        self.contactType = contactType
        self.assistant = assistant
        self.roles = roles
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case contactType
        case assistant
        case participantVO // for decoder
        case participant // for encoder
        case roles = "roleTypes"
        case block
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(participant, forKey: .participant)
        try container.encodeIfPresent(contactType, forKey: .contactType)
        try container.encodeIfPresent(assistant, forKey: .assistant)
        try container.encodeIfPresent(roles, forKey: .roles)
    }
}
