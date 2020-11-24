//
//  CallVO.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class CallVO {
    
    public var id:                      Int?
    public var creatorId:               Int?
    public var type:                    Int?
    public var createTime:              Int?
    public var startTime:               Int?
    public var endTime:                 Int?
    public var status:                  Int?
    public var isGroup:                 Bool?
    public var callParticipants:        [Participant]?
    public var partnerParticipantVO:    Participant?
    
    
    public init(messageContent: JSON) {
        self.id         = messageContent["id"].int
        self.creatorId  = messageContent["creatorId"].int
        self.type       = messageContent["type"].int
        self.createTime = messageContent["createTime"].int
        self.startTime  = messageContent["startTime"].int
        self.endTime    = messageContent["endTime"].int
        self.status     = messageContent["status"].int
        self.isGroup    = messageContent["isGroup"].bool
        
        var tempParticipants: [Participant]?
        for item in messageContent["callParticipants"].arrayValue {
            if ((tempParticipants?.count ?? 0) < 1) {
                tempParticipants = [Participant]()
            }
            tempParticipants!.append(Participant(messageContent: item, threadId: nil))
        }
        self.callParticipants = tempParticipants
        if let partnerParticipantJSON = messageContent["partnerParticipantVO"] as JSON? {
            self.partnerParticipantVO = Participant(messageContent: partnerParticipantJSON, threadId: nil)
        }
    }
    
    public init(id:                     Int,
                creatorId:              Int,
                type:                   Int,
                createTime:             Int,
                startTime:              Int,
                endTime:                Int,
                status:                 Int,
                isGroup:                Bool,
                callParticipants:       [Participant],
                partnerParticipantVO:   Participant?) {
        self.id                     = id
        self.creatorId              = creatorId
        self.type                   = type
        self.createTime             = createTime
        self.startTime              = startTime
        self.endTime                = endTime
        self.status                 = status
        self.isGroup                = isGroup
        self.callParticipants       = callParticipants
        self.partnerParticipantVO   = partnerParticipantVO
    }
    
    public init(theCallVO: CallVO) {
        self.id                     = theCallVO.id
        self.creatorId              = theCallVO.creatorId
        self.type                   = theCallVO.type
        self.createTime             = theCallVO.createTime
        self.startTime              = theCallVO.startTime
        self.endTime                = theCallVO.endTime
        self.status                 = theCallVO.status
        self.isGroup                = theCallVO.isGroup
        self.callParticipants       = theCallVO.callParticipants
        self.partnerParticipantVO   = theCallVO.partnerParticipantVO
    }
    
    public func formatToJSON() -> JSON {
        var participantsArr = [JSON]()
        for item in (self.callParticipants ?? []) {
            participantsArr.append(item.formatToJSON())
        }
        let result: JSON = ["id":                   id ?? NSNull(),
                            "creatorId":            creatorId ?? NSNull(),
                            "type":                 type ?? NSNull(),
                            "createTime":           createTime ?? NSNull(),
                            "startTime":            startTime ?? NSNull(),
                            "endTime":              endTime ?? NSNull(),
                            "status":               status ?? NSNull(),
                            "isGroup":              isGroup ?? NSNull(),
                            "callParticipants":     participantsArr,
                            "partnerParticipantVO": partnerParticipantVO?.formatToJSON() ?? NSNull()]
        return result
    }
    
}
