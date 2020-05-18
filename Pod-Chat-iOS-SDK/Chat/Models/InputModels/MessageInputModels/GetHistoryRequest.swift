//
//  GetHistoryRequest.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodAsyncSDK
import SwiftyJSON

open class GetHistoryRequest: RequestModelDelegates {
    
    public let count:               Int?        // Count of threads to be received
    public let fromTime:            UInt?       // Get messages which have bigger time than given fromTime
    public let fromTimeNanos:       UInt?       //
    public let messageId:           Int?        // Id of single message to get
    public let messageType:         Int?        // Type of messages to get (types should be set by client)
    public let metadataCriteria:    String?     // This JSON will be used to search in message metadata with GraphQL
    public let offset:              Int?        // Offset of select query
    public let order:               String?     // Order of select query (default: DESC)
    public let query:               String?     // Search term to be looked up in messages content
    public let threadId:            Int         // Id of thread to get its history
    public let toTime:              UInt?       // Get messages which have smaller time than given toTime
    public let toTimeNanos:         UInt?       //
    public let uniqueIds:           [String]?   // Array of unique ids to retrieve
    public let userId:              Int?        // Messages of this SSO User
    
    public let typeCode:            String?
    public let uniqueId:            String
    
    public init(count:              Int?,
                fromTime:           UInt?,
                fromTimeNanos:      UInt?,
                messageId:          Int?,
                messageType:        Int?,
                metadataCriteria:   String?,
                offset:             Int?,
                order:              String?,
                query:              String?,
                threadId:           Int,
                toTime:             UInt?,
                toTimeNanos:        UInt?,
                uniqueIds:          [String]?,
                userId:             Int?,
                typeCode:           String?,
                uniqueId:           String?) {
        
        self.count              = count
        self.fromTime           = fromTime
        self.fromTimeNanos      = fromTimeNanos
        self.messageId          = messageId
        self.messageType        = messageType
        self.metadataCriteria   = metadataCriteria
        self.offset             = offset
        self.order              = order
        self.query              = query
        self.threadId           = threadId
        self.toTime             = toTime
        self.toTimeNanos        = toTimeNanos
        self.uniqueIds          = uniqueIds
        self.userId             = userId
        
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? UUID().uuidString
    }
    
    public init(count:              Int?,
                fromTime:           UInt?,
                messageId:          Int?,
                messageType:        Int?,
                metadataCriteria:   String?,
                offset:             Int?,
                order:              String?,
                query:              String?,
                senderId:           Int?,
                threadId:           Int,
                toTime:             UInt?,
                uniqueIds:          [String]?,
                userId:             Int?,
                typeCode:           String?,
                uniqueId:           String?) {
        
        self.count              = count
        self.fromTime           = fromTime
        self.fromTimeNanos      = nil
        self.messageId          = messageId
        self.messageType        = messageType
        self.metadataCriteria   = metadataCriteria
        self.offset             = offset
        self.order              = order
        self.query              = query
        self.threadId           = threadId
        self.toTime             = toTime
        self.toTimeNanos        = nil
        self.uniqueIds          = uniqueIds
        self.userId             = userId
        
        self.typeCode           = typeCode
        self.uniqueId           = uniqueId ?? UUID().uuidString
    }
    
    public init(json: JSON) {
        self.count              = json["count"].int
        self.fromTime           = json["fromTime"].uInt
        self.fromTimeNanos      = json["fromTimeNanos"].uInt
        self.messageId          = json["messageId"].int
        self.messageType        = json["messageType"].int
        self.metadataCriteria   = json["metadataCriteria"].string
        self.offset             = json["offset"].int
        self.order              = json["order"].string
        self.query              = json["query"].string
        self.threadId           = json["threadId"].intValue
        self.toTime             = json["toTime"].uInt
        self.toTimeNanos        = json["toTimeNanos"].uInt
        self.uniqueIds          = json["uniqueIds"].arrayObject as? [String]
        self.userId             = json["userId"].int
        
        self.typeCode           = json["typeCode"].string
        self.uniqueId           = json["uniqueId"].string ?? UUID().uuidString
    }
    
    public func convertContentToJSON() -> JSON {
        var content: JSON = [:]
        content["count"] = JSON(self.count ?? 50)
        content["offset"] = JSON(self.offset ?? 0)
        
        if let from = self.fromTime {
            content["fromTime"] = JSON(from)
        }
        if let fromNano = self.fromTimeNanos {
            content["fromTimeNanos"] = JSON(fromNano)
        }
        if let to = self.toTime {
            content["toTime"] = JSON(to)
        }
        if let toNano = self.toTimeNanos {
            content["toTimeNanos"] = JSON(toNano)
        }
        if let order = self.order {
            content["order"] = JSON(order)
        }
        if let query = self.query {
            let theQuery = MakeCustomTextToSend(message: query).replaceSpaceEnterWithSpecificCharecters()
            content["query"] = JSON(theQuery)
        }
        if let id = self.messageId {
            content["id"] = JSON(id)
        }
        if let userId = self.userId {
            content["userId"] = JSON(userId)
        }
        if let metadataCriteria = self.metadataCriteria {
            let theMeta = MakeCustomTextToSend(message: metadataCriteria).replaceSpaceEnterWithSpecificCharecters()
            content["metadataCriteria"] = JSON(theMeta)
        }
        if let uniqueIds = self.uniqueIds {
            content["uniqueIds"] = JSON(uniqueIds)
        }
        if let messageType = self.messageType {
            content["messageType"] = JSON(messageType)
        }
        
        return content
    }
    
    public func convertContentToJSONArray() -> [JSON] {
        return []
    }
    
}


open class GetHistoryRequestModel: GetHistoryRequest {
    
}

