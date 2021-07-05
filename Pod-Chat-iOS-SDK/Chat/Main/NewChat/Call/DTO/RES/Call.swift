//
//  Call.swift
//  FanapPodChatSDK
//
//  Created by Hamed Hosseini on 6/29/21.
//

import Foundation
public struct Call : Codable , Equatable {
    
    public static func == (lhs: Call, rhs: Call) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public let id : Int
    public let creatorId          : Int
    public let type               : Int
    public let createTime         : Int?
    public let startTime          : Int?
    public let endTime            : Int?
    public let status             : CallStatus?
    public let isGroup            : Bool
    public let callParticipants   : [Participant]?
    public let partnerParticipant : Participant?
    
    public init(id                 : Int,
                creatorId          : Int,
                type               : Int,
                isGroup            : Bool,
                createTime         : Int?            = nil,
                startTime          : Int?            = nil,
                endTime            : Int?            = nil,
                status             : CallStatus?     = nil,
                callParticipants   : [Participant]?  = nil,
                partnerParticipant : Participant?    = nil) {
        self.id                 = id
        self.creatorId          = creatorId
        self.type               = type
        self.createTime         = createTime
        self.startTime          = startTime
        self.endTime            = endTime
        self.status             = status
        self.isGroup            = isGroup
        self.callParticipants   = callParticipants
        self.partnerParticipant = partnerParticipant
    }
    
    private enum CodingKeys:String , CodingKey{
        case id                 = "id"
        case creatorId          = "creatorId"
        case type               = "type"
        case createTime         = "createTime"
        case startTime          = "startTime"
        case endTime            = "endTime"
        case status             = "status"
        case isGroup            = "group"
        case callParticipants   = "callParticipants"
        case partnerParticipant = "partnerParticipantVO"
    }
}
