//
//  Tag.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/23/21.
//

import Foundation
public struct Tag : Codable {
    
    let id              : Int
    let name            : String
    let owner           : Participant
    let active          : Bool
    let tagParticipants : [TagParticipant]?
    
    private enum CodingKeys:String,CodingKey{
        case id              = "id"
        case name            = "name"
        case owner           = "owner"
        case active          = "active"
        case tagParticipants = "tagParticipantVOList"
    }
}
