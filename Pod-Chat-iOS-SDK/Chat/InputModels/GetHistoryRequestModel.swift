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
    
    public let count:               Int?        // Count of threads to be received
//    public let firstMessageId:      Int?
    public let fromTime:            UInt?       // Get messages which have bigger time than given fromTime
//    public let lastMessageId:       Int?
    public let messageId:           Int?        // Id of single message to get
    public let messageType:         Int?        // Type of messages to get (types should be set by client)
    public let metadataCriteria:    JSON?       // This JSON will be used to search in message metadata with GraphQL
    public let offset:              Int?        // Offset of select query
    public let order:               String?     // Order of select query (default: DESC)
    public let query:               String?     // Search term to be looked up in messages content
    public let senderId:            Int?        // Messages of this sender only
    public let threadId:            Int         // Id of thread to get its history
    public let toTime:              UInt?       // Get messages which have smaller time than given toTime
    public let uniqueIds:           [String]?   // Array of unique ids to retrieve
    public let userId:              Int?        // Messages of this SSO User
    
    public let requestTypeCode:     String?
    public let requestUniqueId:     String?
    
//    public let fromTimeNanos:            UInt?   //
//    public let toTimeNanos:              UInt?   //
    
    public init(count:              Int?,
//                firstMessageId:     Int?,
                fromTime:           UInt?,
//                lastMessageId:      Int?,
                messageId:          Int?,
                messageType:        Int?,
                metadataCriteria:   JSON?,
                offset:             Int?,
                order:              String?,
                query:              String?,
                senderId:           Int?,
                threadId:           Int,
                toTime:             UInt?,
                uniqueIds:          [String]?,
                userId:             Int?,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.count              = count
//        self.firstMessageId     = firstMessageId
        self.fromTime           = fromTime
//        self.lastMessageId      = lastMessageId
        self.messageId          = messageId
        self.messageType        = messageType
        self.metadataCriteria   = metadataCriteria
        self.offset             = offset
        self.order              = order
        self.query              = query
        self.senderId           = senderId
        self.threadId           = threadId
        self.toTime             = toTime
        self.uniqueIds          = uniqueIds
        self.userId             = userId
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
    func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["count"] = JSON(self.count ?? 50)
        content["offset"] = JSON(self.offset ?? 0)
//        if let firstMessageId = self.firstMessageId {
//            content["firstMessageId"] = JSON(firstMessageId)
//        }
//        if let lastMessageId = self.lastMessageId {
//            content["lastMessageId"] = JSON(lastMessageId)
//        }
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
        if let id = self.messageId {
            content["id"] = JSON(id)
        }
        if let userId = self.userId {
            content["userId"] = JSON(userId)
        }
        if let metadataCriteria = self.metadataCriteria {
            content["metadataCriteria"] = JSON(metadataCriteria)
        }
        if let uniqueIds = self.uniqueIds {
            content["uniqueIds"] = JSON(uniqueIds)
        }
        if let messageType = self.messageType {
            content["messageType"] = JSON(messageType)
        }
        if let senderId = self.senderId {
            content["senderId"] = JSON(senderId)
        }
//        if let uniqueId = getHistoryInput.uniqueId {
//            content["uniqueId"] = JSON(uniqueId)
//        }
        
        return content
    }
    
}

