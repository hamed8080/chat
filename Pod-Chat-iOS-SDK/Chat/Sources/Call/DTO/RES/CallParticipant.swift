//
//  CallParticipant.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public struct CallParticipant:Codable,Hashable{
    
    public static func == (lhs: CallParticipant, rhs: CallParticipant) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
   
    public var id           : String = UUID().uuidString //only for use swiftui
    public let joinTime     : Int?
    public let leaveTime    : Int?
    public let userId       : Int?
    public let sendTopic    : String
    public let receiveTopic : String?
    public let active       : Bool?
    public let callStatus   : CallStatus?
    public let participant  : Participant?
    public var mute         : Bool
    public var video        : Bool?
    
    public init(
        sendTopic    : String,
        receiveTopic : String?       = nil,
        joinTime     : Int?          = nil,
        leaveTime    : Int?          = nil,
        userId       : Int?          = nil,
        active       : Bool          = true,
        callStatus   : CallStatus?   = nil,
        mute         : Bool          = false,
        video        : Bool?         = nil,
        participant  : Participant?  = nil
    ) {
        self.joinTime     = joinTime
        self.leaveTime    = leaveTime
        self.userId       = userId
        self.sendTopic    = sendTopic
        self.receiveTopic = receiveTopic
        self.active       = active
        self.callStatus   = callStatus
        self.participant  = participant
        self.mute         = mute
        self.video        = video
    }
    
    private enum CodingKeys:String,CodingKey{
        case joinTime     = "joinTime"
        case leaveTime    = "leaveTime"
        case userId       = "userId"
        case sendTopic    = "sendTopic"
        case receiveTopic = "receiveTopic"
        case active       = "active"
        case callStatus   = "callStatus"
        case participant  = "participantVO"
        case mute         = "mute"
        case video        = "video"
    }

    var topics:(topicVideo:String,topicAudio:String){
        return ("Vi-\(sendTopic)","Vo-\(sendTopic)")
    }

}
