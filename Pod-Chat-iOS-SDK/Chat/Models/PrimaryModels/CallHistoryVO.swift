//
//  CallHistoryVO.swift
//  FanapPodChatSDK
//
//  Created by MahyarZhiani on 9/4/1399 AP.
//  Copyright © 1399 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON

open class CallHistoryVO {
    
    public var id:          Int?
    public var creatorId:   Int?
    public var type:        Int?
    public var createTime:  Int?
    public var startTime:   Int?
    public var endTime:     Int?
    public var status:      Int?
    public var isGroup:     Bool?
    
    public init(messageContent: JSON) {
        self.id         = messageContent["id"].int
        self.creatorId  = messageContent["creatorId"].int
        self.type       = messageContent["type"].int
        self.createTime = messageContent["createTime"].int
        self.startTime  = messageContent["startTime"].int
        self.endTime    = messageContent["endTime"].int
        self.status     = messageContent["status"].int
        self.isGroup    = messageContent["isGroup"].bool
    }
    
    public init(id:         Int,
                creatorId:  Int,
                type:       Int,
                createTime: Int,
                startTime:  Int,
                endTime:    Int,
                status:     Int,
                isGroup:    Bool) {
        self.id                     = id
        self.creatorId              = creatorId
        self.type                   = type
        self.createTime             = createTime
        self.startTime              = startTime
        self.endTime                = endTime
        self.status                 = status
        self.isGroup                = isGroup
    }
    
    public init(theCallHistoryVO: CallHistoryVO) {
        self.id                     = theCallHistoryVO.id
        self.creatorId              = theCallHistoryVO.creatorId
        self.type                   = theCallHistoryVO.type
        self.createTime             = theCallHistoryVO.createTime
        self.startTime              = theCallHistoryVO.startTime
        self.endTime                = theCallHistoryVO.endTime
        self.status                 = theCallHistoryVO.status
        self.isGroup                = theCallHistoryVO.isGroup
    }
    
    public func formatToJSON() -> JSON {
        let result: JSON = ["id":                   id ?? NSNull(),
                            "creatorId":            creatorId ?? NSNull(),
                            "type":                 type ?? NSNull(),
                            "createTime":           createTime ?? NSNull(),
                            "startTime":            startTime ?? NSNull(),
                            "endTime":              endTime ?? NSNull(),
                            "status":               status ?? NSNull(),
                            "isGroup":              isGroup ?? NSNull()]
        return result
    }
    
}
