//
//  CallParticipant.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public struct CallParticipant:Codable{
    
    public let id           : Int
    public let joinTime     : Int
    public let leaveTime    : Int
    public let userId       : Int
    public let sendTopic    : String
    public let receiveTopic : String
    public let active       : Bool
    public let callStatus   : CallStatus
    public let participant  : Participant
    
    private enum CodingKeys:String,CodingKey{
        
        case id           = "id"
        case joinTime     = "joinTime"
        case leaveTime    = "leaveTime"
        case userId       = "userId"
        case sendTopic    = "sendTopic"
        case receiveTopic = "receiveTopic"
        case active       = "active"
        case callStatus   = "callStatus"
        case participant  = "participantVO"
    }
}
