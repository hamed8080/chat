//
//  CallParticipantVO.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class CallParticipantVO {
    
    public var id:              Int?
    public var joinTime:        Int?
    public var leaveTime:       Int?
    public var userId:          Int?
    public var sendTopic:       String?
    public var receiveTopic:    String?
    public var active:          Bool?
    public var callStatus:      Int?
    public var participantVO:   Participant?
    
    public init(messageContent: JSON) {
        self.id             = messageContent["id"].int
        self.joinTime       = messageContent["joinTime"].int
        self.leaveTime      = messageContent["leaveTime"].int
        self.userId         = messageContent["userId"].int
        self.sendTopic      = messageContent["sendTopic"].string
        self.receiveTopic   = messageContent["receiveTopic"].string
        self.active         = messageContent["active"].bool
        self.callStatus     = messageContent["callStatus"].int
        
        if let participantVOJSON = messageContent["participantVO"] as JSON? {
            self.participantVO = Participant(messageContent: participantVOJSON, threadId: nil)
        }
    }
    
    public init(id:             Int,
                joinTime:       Int,
                leaveTime:      Int,
                userId:         Int,
                sendTopic:      String,
                receiveTopic:   String,
                active:         Bool,
                callStatus:     Int,
                participantVO:  Participant) {
        self.id             = id
        self.joinTime       = joinTime
        self.leaveTime      = leaveTime
        self.userId         = userId
        self.sendTopic      = sendTopic
        self.receiveTopic   = receiveTopic
        self.active         = active
        self.callStatus     = callStatus
        self.participantVO  = participantVO
    }
    
    public init(theCallParticipantVO: CallParticipantVO) {
        self.id             = theCallParticipantVO.id
        self.joinTime       = theCallParticipantVO.joinTime
        self.leaveTime      = theCallParticipantVO.leaveTime
        self.userId         = theCallParticipantVO.userId
        self.sendTopic      = theCallParticipantVO.sendTopic
        self.receiveTopic   = theCallParticipantVO.receiveTopic
        self.active         = theCallParticipantVO.active
        self.callStatus     = theCallParticipantVO.callStatus
        self.participantVO  = theCallParticipantVO.participantVO
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["id":               id ?? NSNull(),
                            "joinTime":         joinTime ?? NSNull(),
                            "leaveTime":        leaveTime ?? NSNull(),
                            "userId":           userId ?? NSNull(),
                            "sendTopic":        sendTopic ?? NSNull(),
                            "receiveTopic":     receiveTopic ?? NSNull(),
                            "active":           active ?? NSNull(),
                            "callStatus":       callStatus ?? NSNull(),
                            "participantVO":    participantVO?.formatToJSON() ?? NSNull()]
        return result
    }
    
}
