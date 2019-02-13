//
//  UnblockContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class UnblockContactsRequestModel {
    
    public let blockId:     Int
    public let contactId:   Int?
    public let threadId:    Int?
    public let typeCode:    String?
    public let userId:      Int?
    
    public init(blockId: Int, contactId: Int?, threadId: Int?, typeCode: String?, userId: Int?) {
        self.blockId    = blockId
        self.contactId  = contactId
        self.threadId   = threadId
        self.typeCode   = typeCode
        self.userId     = userId
    }
    
}

