//
//  GetThreadParticipantsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class GetThreadParticipantsRequestModel {
    
    public let threadId:            Int
    public let count:               Int?
    public let offset:              Int?
    public let firstMessageId:      Int?
    public let lastMessageId:       Int?
    public let name:                String?
    public let typeCode:            String?
    
    init(threadId:          Int,
         count:             Int?,
         offset:            Int?,
         firstMessageId:    Int?,
         lastMessageId:     Int?,
         name:              String?,
         typeCode:          String?) {
        
        self.threadId           = threadId
        self.count              = count
        self.offset             = offset
        self.firstMessageId     = firstMessageId
        self.lastMessageId      = lastMessageId
        self.name               = name
        self.typeCode           = typeCode
    }
    
}

