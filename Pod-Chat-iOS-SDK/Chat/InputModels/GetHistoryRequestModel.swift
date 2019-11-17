//
//  GetHistoryRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation
import SwiftyJSON


open class GetHistoryRequestModel {
    
    public let count:               Int?    
    public let firstMessageId:      Int?
    public let fromTime:            UInt?
    public let lastMessageId:       Int?
    public let messageId:           Int?
    public let metadataCriteria:    JSON?
    public let offset:              Int?
    public let order:               String?
    public let query:               String?
    public let threadId:            Int
    public let toTime:              UInt?
    public let uniqueIds:           [String]?
    public let requestTypeCode:     String?
    public let requestUniqueId:     String?
    
//    public let fromTimeNanos:            UInt?   //
//    public let toTimeNanos:              UInt?   //
    
    public init(count:              Int?,
                firstMessageId:     Int?,
                fromTime:           UInt?,
                lastMessageId:      Int?,
                messageId:          Int?,
                metadataCriteria:   JSON?,
                offset:             Int?,
                order:              String?,
                query:              String?,
                threadId:           Int,
                toTime:             UInt?,
                uniqueIds:          [String]?,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.count              = count
        self.firstMessageId     = firstMessageId
        self.fromTime           = fromTime
        self.lastMessageId      = lastMessageId
        self.messageId          = messageId
        self.metadataCriteria   = metadataCriteria
        self.offset             = offset
        self.order              = order
        self.query              = query
        self.threadId           = threadId
        self.toTime             = toTime
        self.uniqueIds          = uniqueIds
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["count"] = JSON(self.count ?? 50)
        content["offset"] = JSON(self.offset ?? 0)
        if let firstMessageId = self.firstMessageId {
            content["firstMessageId"] = JSON(firstMessageId)
        }
        if let lastMessageId = self.lastMessageId {
            content["lastMessageId"] = JSON(lastMessageId)
        }
        if let from = self.fromTime {
            if let first13Digits = Int(exactly: (from / 1000000)) {
                content["fromTime"] = JSON(first13Digits)
                content["fromTimeNanos"] = JSON(Int(exactly: (from - UInt(first13Digits * 1000000)))!)
            }
        }
        if let to = self.toTime {
            if let first13Digits = Int(exactly: (to / 1000000)) {
                content["toTime"] = JSON(first13Digits)
                content["toTimeNanos"] = JSON(Int(exactly: (to - UInt(first13Digits * 1000000)))!)
            }
        }
        if let order = self.order {
            content["order"] = JSON(order)
        }
        if let query = self.query {
            content["query"] = JSON(query)
        }
        if let metadataCriteria = self.metadataCriteria {
            content["metadataCriteria"] = JSON(metadataCriteria)
        }
        if let uniqueIds = self.uniqueIds {
            content["uniqueIds"] = JSON(uniqueIds)
        }
//        if let uniqueId = getHistoryInput.uniqueId {
//            content["uniqueId"] = JSON(uniqueId)
//        }
        
        return content
    }
    
}

