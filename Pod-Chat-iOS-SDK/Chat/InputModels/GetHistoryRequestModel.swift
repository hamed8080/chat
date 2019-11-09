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
    
}

