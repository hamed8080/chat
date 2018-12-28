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
    
    public let threadId:            Int
    public let count:               Int?
    public let offset:              Int?
    public let firstMessageId:      Int?
    public let lastMessageId:       Int?
    public let order:               String?
    public let query:               String?
    public let typeCode:            String?
    public let metadataCriteria:    JSON?
    
    public init(threadId:          Int,
                count:             Int?,
                offset:            Int?,
                firstMessageId:    Int?,
                lastMessageId:     Int?,
                order:             String?,
                query:             String?,
                typeCode:          String?,
                metadataCriteria:  JSON?) {
        
        self.threadId           = threadId
        self.count              = count
        self.offset             = offset
        self.firstMessageId     = firstMessageId
        self.lastMessageId      = lastMessageId
        self.order              = order
        self.query              = query
        self.typeCode           = typeCode
        self.metadataCriteria   = metadataCriteria
    }
    
}

