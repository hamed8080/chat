//
//  Assistant.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 11/1/21.
//

import Foundation

open class Assistant : Codable {
    
    public var contactType : String?
    public var assistant   : Invitee?
    public var participant : Participant?
    public var roleTypes   : [Roles]?
    public var block       : Bool
    
    private enum CodingKeys : String , CodingKey{
        case contactType   = "contactType"
        case assistant     = "assistant"
        case participantVO = "participantVO" // for decoder
        case participant   = "participant" // for encoder
        case roleTypes     = "roleTypes"
        case block         = "block"
    }
    
    public init(assistant:      Invitee?     = nil,
                contactType:    String?      = nil,
                participant:    Participant? = nil,
                block:          Bool         = false,
                roleTypes:      [Roles]?     = nil) {
        self.contactType    = contactType
        self.assistant      = assistant
        self.participant    = participant
        self.roleTypes      = roleTypes
        self.block          = block
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy : CodingKeys.self)
        contactType   = try container?.decodeIfPresent(String.self, forKey: .contactType)
        assistant     = try container?.decodeIfPresent(Invitee.self, forKey : .assistant)
        participant   = try container?.decodeIfPresent(Participant.self, forKey : .participantVO)
        roleTypes     = try container?.decodeIfPresent([Roles].self, forKey : .roleTypes)
        block         = (try container?.decodeIfPresent(Bool.self, forKey : .block)) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(participant, forKey: .participant)
        try container.encodeIfPresent(contactType, forKey: .contactType)
        try container.encodeIfPresent(assistant, forKey: .assistant)
        try container.encodeIfPresent(roleTypes, forKey: .roleTypes)
    }
    
}

public struct AssistantEventModel{
    let assistants:[Assistant]
    let type:AssistantEventType
}

public enum AssistantEventType{
    case REGISTER_ASSISTANT
    case BLOCK_ASSISTANT
    case UNBLOCK_ASSISTANT
    case DEACTIVE_ASSISTANTS
    
}
