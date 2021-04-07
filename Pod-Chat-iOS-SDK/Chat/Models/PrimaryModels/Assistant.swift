//
//  Assistant.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 12/9/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation


open class Assistant : Codable {
    
    public var contactType : String?
    public var assistant   : Invitee?
    public var participant : Participant?
    public var roleTypes   : [Roles]?
    
    
    private enum CodingKeys : String , CodingKey{
        case contactType   = "contactType"
        case assistant     = "assistant"
        case participantVO = "participantVO" // for decoder
        case participant   = "participant" // for encoder
        case roleTypes     = "roleTypes"
    }
    
    public init(assistant:      Invitee,
                contactType:    String?      = nil,
                participant:    Participant? = nil,
                roleTypes:      [Roles]?     = nil) {
        self.contactType    = contactType
        self.assistant      = assistant
        self.participant    = participant
        self.roleTypes      = roleTypes
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy : CodingKeys.self)
        contactType   = try container?.decodeIfPresent(String.self, forKey: .contactType)
        assistant     = try container?.decodeIfPresent(Invitee.self, forKey : .assistant)
        participant   = try container?.decodeIfPresent(Participant.self, forKey : .participantVO)
        roleTypes     = try container?.decodeIfPresent([Roles].self, forKey : .roleTypes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(participant, forKey: .participant)
        try container.encodeIfPresent(contactType, forKey: .contactType)
        try container.encodeIfPresent(assistant, forKey: .assistant)
        try container.encodeIfPresent(roleTypes, forKey: .roleTypes)
    }
    
}
