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
    public let typeCode:        String?
    public let uniqueId:        String?
    
    public init(admin:          Bool?,
                count:          Int?,
                firstMessageId: Int?,
                lastMessageId:  Int?,
                name:           String?,
                offset:         Int?,
                threadId:       Int,
                typeCode:       String?,
                uniqueId:       String?) {
        
        self.admin          = admin
        self.count          = count
        self.firstMessageId = firstMessageId
        self.lastMessageId  = lastMessageId
        self.name           = name
        self.offset         = offset
        self.threadId       = threadId
        self.typeCode       = typeCode
        self.uniqueId       = uniqueId
    }
    
}

