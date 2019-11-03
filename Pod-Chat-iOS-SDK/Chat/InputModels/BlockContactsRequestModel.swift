//
//  BlockContactsRequestModel.swift
//  Chat
//
//  Created by Mahyar Zhiani on 10/1/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import Foundation

open class BlockContactsRequestModel {
    
    public let contactId:       Int?
    public let threadId:        Int?
    public let userId:          Int?
    public let requestTypeCode: String?
    public let requestUniqueId: String?
    
    public init(contactId:          Int?,
                threadId:           Int?,
                userId:             Int?,
                requestTypeCode:    String?,
                requestUniqueId:    String?) {
        
        self.contactId          = contactId
        self.threadId           = threadId
        self.userId             = userId
        self.requestTypeCode    = requestTypeCode
        self.requestUniqueId    = requestUniqueId
    }
    
}

