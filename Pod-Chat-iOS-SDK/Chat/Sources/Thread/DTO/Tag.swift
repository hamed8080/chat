//
//  Tag.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/23/21.
//

import Foundation
public struct Tag : Codable {
    
    public var id              : Int
    public var name            : String
    public var owner           : Participant
    public var active          : Bool
    public var tagParticipants : [TagParticipant]?
    
    public init(id: Int, name: String, owner: Participant, active: Bool, tagParticipants: [TagParticipant]? = nil) {
        self.id              = id
        self.name            = name
        self.owner           = owner
        self.active          = active
        self.tagParticipants = tagParticipants
    }
    
    private enum CodingKeys:String,CodingKey{
        case id              = "id"
        case name            = "name"
        case owner           = "owner"
        case active          = "active"
        case tagParticipants = "tagParticipantVOList"
    }
}
