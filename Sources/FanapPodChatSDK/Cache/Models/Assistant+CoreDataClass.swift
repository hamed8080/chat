//
//  Assistant+CoreDataClass.swift
//  ChatApplication
//
//  Created by hamed on 1/5/23.
//
//

import CoreData
import Foundation

public class Assistant: NSManagedObject {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context] as? NSManagedObjectContext else {
            fatalError("NSManagedObjectContext is not present in the userInfo!")
        }
        self.init(context: context)
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        contactType = try container?.decodeIfPresent(String.self, forKey: .contactType)
        assistant = try container?.decodeIfPresent(Invitee.self, forKey: .assistant)
        participant = try container?.decodeIfPresent(Participant.self, forKey: .participantVO)
        roles = try container?.decodeIfPresent([Roles].self, forKey: .roles)
        block = (try container?.decodeIfPresent(Bool.self, forKey: .block)) ?? false
    }

    public convenience init(
        context: NSManagedObjectContext,
        assistant: Invitee? = nil,
        contactType: String? = nil,
        participant: Participant? = nil,
        block: Bool = false,
        roleTypes: [Roles]? = nil
    ) {
        self.init(context: context)
        self.contactType = contactType
        self.assistant = assistant
        self.participant = participant
        roles = roleTypes
        self.block = block
    }
}

extension Assistant: Codable {
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
