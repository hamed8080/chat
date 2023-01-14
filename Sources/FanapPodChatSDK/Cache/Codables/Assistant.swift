//
//  Assistant.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

open class Assistant: Codable {
    public var id: Int?
    public var contactType: String?
    public var assistant: Invitee?
    public var participant: Participant?
    public var roles: [Roles]?
    public var block: Bool?

    public required init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        contactType = try container?.decodeIfPresent(String.self, forKey: .contactType)
        assistant = try container?.decodeIfPresent(Invitee.self, forKey: .assistant)
        participant = try container?.decodeIfPresent(Participant.self, forKey: .participantVO)
        roles = try container?.decodeIfPresent([Roles].self, forKey: .roles)
        block = (try container?.decodeIfPresent(Bool.self, forKey: .block)) ?? false
    }

    public init(contactType: String? = nil, assistant: Invitee? = nil, participant: Participant? = nil, roles: [Roles]? = nil, block: Bool? = nil) {
        self.contactType = contactType
        self.assistant = assistant
        self.participant = participant
        self.roles = roles
        self.block = block
    }

    private enum CodingKeys: String, CodingKey {
        case contactType
        case assistant
        case participantVO // for decoder
        case participant // for encoder
        case roles = "roleTypes"
        case block
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(participant, forKey: .participant)
        try container.encodeIfPresent(contactType, forKey: .contactType)
        try container.encodeIfPresent(assistant, forKey: .assistant)
        try container.encodeIfPresent(roles, forKey: .roles)
    }
}
