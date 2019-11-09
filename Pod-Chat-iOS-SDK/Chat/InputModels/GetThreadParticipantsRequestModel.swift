//
//  GetThreadParticipantsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class GetThreadParticipantsRequestModel {
    
    public let admin:           Bool?
    public let count:           Int?
    public let firstMessageId:  Int?
    public let lastMessageId:   Int?
    public let name:            String?
    public let offset:          Int?
    public let threadId:        Int
    public let requestTypeCode: String?
    public let requestUniqueId: String?
    
    public init(admin:              Bool?,
                count:              Int?,
                firstMessageId:     Int?,
                lastMessageId:      Int?,
                name:               String?,
                offset:             Int?,
                threadId:           Int,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.admin              = admin
        self.count              = count
        self.firstMessageId     = firstMessageId
        self.lastMessageId      = lastMessageId
        self.name               = name
        self.offset             = offset
        self.threadId           = threadId
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
}

